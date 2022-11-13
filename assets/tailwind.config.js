const colors = require('tailwindcss/colors');

module.exports = {
  mode: 'jit',
  purge: [
    '../lib/binshop_web/(auth|common|web)/(live|views)/**',
    '../lib/binshop_web/(auth|common|web)/templates/**',
    '../lib/binshop_web/(auth|common|web)/live/**'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      maven: ['Maven Pro', 'Arial', 'Helvetica', 'sans-serif'],
      mont: ['Montserrat', 'sans-serif']
    },
    colors: {
      ...colors,
      binario: {
        100: '#e0ebbd',
        200: '#dee8c5',
        300: '#9ed19e',
        400: '#3d8078',
        500: '#2a635c',
        600: '#1e4641',
        700: '#2d635d',
        800: '#324b45',
        900: '#42694966',
      },
    },
    extend: {
      transitionProperty: {
        'right': 'right',
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
