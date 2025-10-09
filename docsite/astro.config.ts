import { defineConfig } from 'astro/config';
import type { AstroUserConfig } from 'astro';
import starlight from '@astrojs/starlight';

import tailwindcss from '@tailwindcss/vite';

const isLocal = process.env.LOCAL_DOCS;

const config: AstroUserConfig<never, never, never> = {
    base: '/mcbox',
    integrations: [
        starlight({
            title: '$_mcbox',
            social: [
                {
                    icon: 'github',
                    label: 'GitHub',
                    href: 'https://github.com/andreswebs/mcbox',
                },
            ],
            sidebar: [
                {
                    label: 'Guides',
                    items: [
                        // Each item here is one entry in the navigation menu.
                        { label: 'Getting Started', slug: 'guides/getting-started' },
                        { label: 'Adding Tools', slug: 'guides/adding-tools' },
                        { label: 'Development', slug: 'guides/development' },
                    ],
                },
                {
                    label: 'Architecture',
                    items: [
                        { label: 'Library and Server', slug: 'architecture/library-and-server' },
                        {
                            label: 'Error Handling and Logging',
                            slug: 'architecture/error-handling',
                        },
                    ],
                },
                {
                    label: 'Reference',
                    autogenerate: { directory: 'reference' },
                },
            ],
            customCss: ['./src/styles/global.css'],
        }),
    ],
    vite: {
        // @ts-expect-error // (2025-10-01) safe to ignore, will be fixed in Astro 6 - see: https://github.com/withastro/astro/issues/14030
        plugins: [tailwindcss()],
    },
};

if (!isLocal) {
    config.site = 'https://andreswebs.github.io';
}

// https://astro.build/config
export default defineConfig(config);
