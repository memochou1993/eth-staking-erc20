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
    'no-console': 'off',
    'no-undef': 'off',
    'prefer-destructuring': 'off',
    'no-unused-vars': 'off',
  },
};
