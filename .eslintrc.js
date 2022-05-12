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
    'no-undef': 'off',
    'no-unused-vars': 'off',
    'prefer-destructuring': 'off',
  },
};
