module.exports = {
  extraFormats: ['avif', 'webp'],
  original: {
    maxWidth: 2560,
    maxHeight: 1440,
    allowedFormats: ['jpeg', 'png', 'gif'],
    fallbackFormat: 'png',
  },
  sizes: [
    {
      suffix: '-sm',
      width: 640,
    },
    {
      suffix: '-md',
      width: 1080,
    },
    {
      suffix: '-lg',
      width: 1920,
    },
  ],
};
