module.exports = {
  extends: 'airbnb',
  env: {
    browser: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: '2020',
  },
  rules: {
    'max-len': 'off',
    'no-console': 'off',
    'no-new': 'off',
    'no-undef': 'off',
  },
  overrides: [
    {
      files: [
        'test/**/*.js',
      ],
      rules: {
        'no-underscore-dangle': 'off',
        'no-promise-executor-return': 'off',
      },
    },
  ],
};
