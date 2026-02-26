const Music = require('../models/Music');
const Stream = require('../models/Stream');
const { getFromCache, setCache } = require('../config/redis');
const logger = require('../utils/logger');

exports.getMusicList = async (req, res, next) => {
  try {
    const { genre, mood, search, page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const query = { isActive: true };
    if (genre) query.genre = genre;
    if (mood) query.mood = mood;

    let findQuery = Music.find(query);

    if (search) {
      findQuery = Music.find({
        ...query,
        $text: { $search: search },
      }, { score: { $meta: 'textScore' } }).sort({ score: { $meta: 'textScore' } });
    } else {
      findQuery = findQuery.sort({ playCount: -1 });
    }

    const [music, total] = await Promise.all([
      findQuery.skip(skip).limit(parseInt(limit)).lean(),
      Music.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: music,
      pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / parseInt(limit)) },
    });
  } catch (error) {
    next(error);
  }
};

exports.getMusicById = async (req, res, next) => {
  try {
    const { musicId } = req.params;

    const music = await Music.findById(musicId).lean();
    if (!music || !music.isActive) {
      return res.status(404).json({ success: false, message: 'Music not found' });
    }

    res.json({ success: true, data: music });
  } catch (error) {
    next(error);
  }
};

exports.getGenres = async (req, res, next) => {
  try {
    const cacheKey = 'music:genres';
    let genres = await getFromCache(cacheKey);

    if (!genres) {
      const result = await Music.aggregate([
        { $match: { isActive: true } },
        { $group: { _id: '$genre', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
      ]);

      genres = result.map(r => ({ genre: r._id, count: r.count }));
      await setCache(cacheKey, genres, 3600);
    }

    res.json({ success: true, data: genres });
  } catch (error) {
    next(error);
  }
};

exports.getTrending = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const cacheKey = `music:trending:${limit}`;

    let music = await getFromCache(cacheKey);
    if (!music) {
      music = await Music.find({ isActive: true })
        .sort({ playCount: -1 })
        .limit(limit)
        .lean();
      await setCache(cacheKey, music, 600);
    }

    res.json({ success: true, data: music });
  } catch (error) {
    next(error);
  }
};

exports.setStreamMusic = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { musicId } = req.body;

    const stream = await Stream.findOne({ streamId, streamerId: req.user._id, status: 'live' });
    if (!stream) {
      return res.status(404).json({ success: false, message: 'Stream not found or not live' });
    }

    if (!musicId) {
      stream.backgroundMusic = null;
      await stream.save();
      return res.json({ success: true, message: 'Background music stopped' });
    }

    const music = await Music.findById(musicId).lean();
    if (!music || !music.isActive) {
      return res.status(404).json({ success: false, message: 'Music not found' });
    }

    stream.backgroundMusic = {
      musicId: music._id,
      title: music.title,
      artist: music.artist,
      audioUrl: music.audioUrl,
      startedAt: new Date(),
    };

    await stream.save();
    await Music.findByIdAndUpdate(musicId, { $inc: { playCount: 1 } });

    res.json({ success: true, data: stream.backgroundMusic, message: 'Background music set' });
  } catch (error) {
    next(error);
  }
};
