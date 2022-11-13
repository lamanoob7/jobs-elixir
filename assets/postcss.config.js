
const pImport = require('postcss-import');
const tailwindcss = require('tailwindcss');
const autoprefixer = require('autoprefixer');
const cssnano = require('cssnano');

module.exports = {
  plugins: [
    pImport(),
    tailwindcss({}),
    autoprefixer(),
    process.env.NODE_ENV == 'production' && cssnano(),
  ],
}
