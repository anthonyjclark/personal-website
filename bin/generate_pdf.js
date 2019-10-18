const build_mode = process.env.BUILD_MODE;

const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    const url = (build_mode === "release")
        ? 'https://people.missouristate.edu/AnthonyClark/cv/'
        : 'http://localhost:8080/cv/';

    console.log(url);

    await page.goto(url, { waitUntil: 'networkidle2' });
    await page.pdf({ path: 'cv.pdf' });

    await browser.close();
})();
