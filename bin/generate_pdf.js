const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    // https://people.missouristate.edu/AnthonyClark/cv/
    await page.goto('https://people.missouristate.edu/AnthonyClark/cv/', {
        waitUntil: 'networkidle2'
    });
    await page.pdf({ path: 'cv.pdf' });

    await browser.close();
})();
