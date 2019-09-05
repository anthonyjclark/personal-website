const ENV = "development";
// const ENV = "release";

const postcss = require('postcss');
const autoprefixer = require('autoprefixer');
const precss = require('precss');

let format;
if (ENV === "development") {
    format = require("stylefmt");
} else {
    format = require("cssnano");
}

const processor = postcss([autoprefixer, precss, format]);

module.exports = function (eleventyConfig) {

    eleventyConfig.addPassthroughCopy("src/static/");
    eleventyConfig.addPassthroughCopy("src/web.config");

    eleventyConfig.addNunjucksAsyncFilter("postcss", function (css, callback) {
        processor.process(css, { from: undefined }).then(result => callback(null, result.css));
    });

    return {
        dir: {
            input: "src",
            output: "dist"
        }
    };
};
