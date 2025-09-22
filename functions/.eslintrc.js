module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended",
    "prettier",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
    "/generated/**/*", // Ignore generated files.
    "**/*.js", // Ignore JavaScript files (only lint TypeScript)
  ],
  plugins: ["@typescript-eslint", "import", "prettier"],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    // off max line length
    "max-len": "off",
    // ignore unused variables
    "@typescript-eslint/no-unused-vars": "off",
    // missing JSDoc comments
    "require-jsdoc": "off",
    // Let Prettier handle formatting
    "prettier/prettier": "error",
  },
};
