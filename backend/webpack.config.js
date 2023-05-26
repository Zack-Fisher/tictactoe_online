const path = require('path');

module.exports = {
    target: 'node',

    cache: true,
    watch: true,

    entry: './src/index.js',
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'backend.js',
    },
    module: {
        rules: [
        {
            test: /\.js$/,
            exclude: /node_modules/,
            use: {
            loader: 'babel-loader',
            options: {
                presets: ['@babel/preset-env'],
            },
            },
        },
        ],
    },
};
