/**
 * @see https://prettier.io/docs/configuration
 * @type {import('prettier').Config}
 */
const config = {
    trailingComma: 'es5',
    useTabs: false,
    tabWidth: 4,
    printWidth: 100,
    semi: true,
    singleQuote: true,
    plugins: ['prettier-plugin-astro', 'prettier-plugin-tailwindcss'],
    tailwindStylesheet: './src/styles/global.css',
    overrides: [
        {
            files: '*.astro',
            options: {
                parser: 'astro',
            },
        },
    ],
};

export default config;
