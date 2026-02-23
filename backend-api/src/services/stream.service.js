const { v4: uuidv4 } = require('uuid');
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const Stream = require('../models/Stream');
const User = require('../models/User');
const { setCache, deleteCache, addToSortedSet } = require('../config/redis');
const logger = require('../utils/logger');

const AGORA_APP_ID = process.env.AGORA_APP_ID;
const AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE;

function generateAgoraToken(channelName, uid, role = RtcRole.PUBLISHER) {
  if (!AGORA_APP_ID || !AGORA_APP_CERTIFICATE) {
    return 'dev_token';
  }

  const expirationTimeInSeconds = 3600 * 4;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  return RtcTokenBuilder.buildTokenWithUid(
    AGORA_APP_ID,
    AGORA_APP_CERTIFICATE,
    channelName,
    uid,
    role,
    privilegeExpiredTs
  );
}

async function startStream({
  streamerId,
  title,
  description,
  category,
  tags,
  privacy,
  recordingEnabled,
  thumbnail,
}) {
  const streamId = uuidv4();
  const channelName = `stream_${streamId.replace(/-/g, '')}`;
  const uid = Math.floor(Math.random() * 100000) + 1;

  const token = generateAgoraToken(channelName, uid, RtcRole.PUBLISHER);

  const stream = new Stream({
    streamId,
    streamerId,
    title,
    description,
    category,
    tags: tags || [],
    thumbnail,
    settings: {
      privacy: privacy || 'public',
      recordingEnabled: recordingEnabled || false,
    },
    agora: {
      channelName,
      token,
      uid,
      appId: AGORA_APP_ID,
    },
    status: 'live',
    startedAt: new Date(),
    stats: { currentViewers: 0, peakViewers: 0 },
  });

  await stream.save();

  await User.updateOne(
    { _id: streamerId },
    { $inc: { 'stats.totalStreams': 1 } }
  );

  await setCache(`stream:${streamId}`, stream.toObject(), 3600);
  await addToSortedSet('live_streams', Date.now(), streamId);
  await addToSortedSet(`live_streams:${category}`, Date.now(), streamId);

  return {
    stream,
    agoraConfig: {
      channelName,
      token,
      uid,
      appId: AGORA_APP_ID || '',
    },
  };
}

async function endStream(streamId, streamerId) {
  const stream = await Stream.findOne({ streamId });
  if (!stream) throw new Error('Stream not found');

  if (stream.streamerId.toString() !== streamerId.toString()) {
    throw new Error('Not authorized to end this stream');
  }

  const duration = stream.startedAt
    ? Math.floor((Date.now() - stream.startedAt.getTime()) / 1000)
    : 0;

  await Stream.updateOne(
    { streamId },
    {
      $set: {
        status: 'ended',
        endedAt: new Date(),
        'stats.duration': duration,
      },
    }
  );

  await User.updateOne(
    { _id: stream.streamerId },
    { $inc: { 'stats.totalStreamDuration': duration } }
  );

  await deleteCache(`stream:${streamId}`);
  await deleteCache(`viewers:${streamId}`);

  return { streamId, duration };
}

async function joinStream(streamId, userId) {
  const stream = await Stream.findOne({ streamId, status: 'live' });
  if (!stream) throw new Error('Stream not found or not live');

  const uid = Math.floor(Math.random() * 1000000) + 100000;
  const token = generateAgoraToken(
    stream.agora.channelName,
    uid,
    RtcRole.SUBSCRIBER
  );

  const isCoHost = stream.coHosts.some(id => id.toString() === userId.toString());
  const isHost = stream.streamerId.toString() === userId.toString();

  const role = isHost || isCoHost ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;
  const roleToken = generateAgoraToken(stream.agora.channelName, uid, role);

  await Stream.updateOne(
    { streamId },
    {
      $addToSet: { activeViewers: userId },
      $inc: { 'stats.totalViews': 1 },
    }
  );

  await updateViewerCount(streamId);

  return {
    agoraConfig: {
      channelName: stream.agora.channelName,
      token: roleToken,
      uid,
      appId: AGORA_APP_ID || '',
    },
    isHost: isHost || isCoHost,
    streamSettings: stream.settings,
  };
}

async function leaveStream(streamId, userId) {
  await Stream.updateOne(
    { streamId },
    { $pull: { activeViewers: userId } }
  );
  await updateViewerCount(streamId);
}

async function updateViewerCount(streamId) {
  const stream = await Stream.findOne({ streamId });
  if (!stream) return;

  const viewerCount = stream.activeViewers.length;
  const peakViewers = Math.max(viewerCount, stream.stats.peakViewers);

  await Stream.updateOne(
    { streamId },
    {
      $set: {
        'stats.currentViewers': viewerCount,
        'stats.peakViewers': peakViewers,
      },
    }
  );

  await addToSortedSet('live_by_viewers', viewerCount, streamId);

  return viewerCount;
}

async function getLiveStreams({ page = 1, pageSize = 20, category, sortBy = 'viewers' }) {
  const query = { status: 'live', isHidden: false };
  if (category) query.category = category;

  let sortOptions = {};
  switch (sortBy) {
    case 'newest':
      sortOptions = { startedAt: -1 };
      break;
    case 'trending':
      sortOptions = { trendingScore: -1 };
      break;
    case 'viewers':
    default:
      sortOptions = { 'stats.currentViewers': -1 };
  }

  const [streams, total] = await Promise.all([
    Stream.find(query)
      .populate('streamerId', 'username profile.displayName profile.avatar profile.verified profile.level')
      .sort(sortOptions)
      .skip((page - 1) * pageSize)
      .limit(pageSize)
      .lean(),
    Stream.countDocuments(query),
  ]);

  return {
    items: streams.map(normalizeStream),
    total,
    page,
    pageSize,
    hasMore: page * pageSize < total,
  };
}

function normalizeStream(stream) {
  const streamerData = stream.streamerId;
  return {
    ...stream,
    streamer: streamerData ? {
      userId: streamerData._id,
      username: streamerData.username,
      displayName: streamerData.profile?.displayName,
      avatar: streamerData.profile?.avatar,
      verified: streamerData.profile?.verified,
      level: streamerData.profile?.level,
    } : null,
  };
}

module.exports = {
  startStream,
  endStream,
  joinStream,
  leaveStream,
  getLiveStreams,
  generateAgoraToken,
  updateViewerCount,
  normalizeStream,
};
