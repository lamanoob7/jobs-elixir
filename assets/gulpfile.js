const fs = require('fs');
const { src, dest, parallel, lastRun, watch, series } = require('gulp');
const plumber = require('gulp-plumber');
const { gulpResponsiveImages, gulpCollectManifest } = require('@binario/image-optimizer');



const GULP_OPTS = { root: "../" };

const imagePreset = require('./image-presets');

const ensurePrivStatic = (cb) => {
  if(!fs.existsSync(`${__dirname}/../priv/static`)) {
    fs.mkdirSync(`${__dirname}/../priv/static`);
  }
  cb();
};

const images = () => src('./images/**/*', GULP_OPTS)
  .pipe(plumber())
  .pipe(gulpResponsiveImages({ imagePreset }))
  .pipe(gulpCollectManifest({ path: `${__dirname}/../priv/static/image-manifest.json` }))
  .pipe(dest('../priv/static/images'));

const imagesIncremental = () => src('./images/**/*', { since: lastRun(imagesIncremental) })
  .pipe(plumber())
  .pipe(gulpResponsiveImages({ imagePreset }))
  .pipe(gulpCollectManifest({
    path: `${__dirname}/../priv/static/image-manifest.json`,
    mergeExisting: true,
  }))
  .pipe(dest('../priv/static/images'));

const copyStatic = () => src('./static/**/*', GULP_OPTS)
  .pipe(dest('../priv/static'));

const build = series(ensurePrivStatic, parallel(images, copyStatic));

const watcher = () => {
  watch('./images/**/*', GULP_OPTS, imagesIncremental);
  watch('./static/**/*', GULP_OPTS, copyStatic);
};

const dev = (cb) => {
  series(ensurePrivStatic, parallel(imagesIncremental, copyStatic), watcher)(cb);
};

module.exports = {
  images,
  copyStatic,
  build,
  dev,
};
