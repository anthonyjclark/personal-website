const ENV = "development";
// const ENV = "release";

const postcss = require('postcss');
const autoprefixer = require('autoprefixer');
const precss = require('precss');

const md = require('markdown-it')({
    html: true,
    linkify: true,
    typographer: true,
    breaks: true
});

let format;
if (ENV === "development") {
    format = require("stylefmt");
} else {
    format = require("cssnano");
}

const processor = postcss([autoprefixer, precss, format]);

const MONTHS = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
];


module.exports = function (eleventyConfig) {

    eleventyConfig.addPassthroughCopy("src/static/");
    eleventyConfig.addPassthroughCopy("src/web.config");

    eleventyConfig.addNunjucksAsyncFilter("postcss", function (css, callback) {
        processor.process(css, { from: undefined }).then(result => callback(null, result.css));
    });

    eleventyConfig.addNunjucksFilter("markdown", function (mdown) {
        return md.render(mdown);
    });

    eleventyConfig.addNunjucksFilter("cvdate", function (dateString) {

        if (typeof dateString === "undefined" || dateString.trim().length === 0) {
            return "";
        }

        const dates = dateString.trim().split(' to ').map((d) => new Date(d));
        const first_month = MONTHS[dates[0].getMonth()].slice(0, 3);
        const first_year = dates[0].getFullYear();
        let date = first_month;
        if (dates.length > 1) {
            if (dateString.includes('present')) {
                date += '&nbsp;' + first_year + ' to present';
            } else {
                const second_month = MONTHS[dates[1].getMonth() - 1].slice(0, 3);
                const second_year = dates[1].getFullYear();

                if (first_year !== second_year) {
                    date += '&nbsp;' + first_year;
                }

                date += ' to ' + second_month + '&nbsp;' + second_year;
            }
        } else {
            date += '&nbsp;' + first_year;
        }
        return date;
    });

    return {
        dir: {
            input: "src",
            output: "dist"
        },
        pathPrefix: (ENV === "development") ? "/" : "/eleventy-base-blog/"
    };
};
