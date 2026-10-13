# X Paid Partnership Blocker

Hides posts with X's **Paid partnership** disclosure, including posts loaded as you scroll. Uses the disclosure's policy link, not keywords. No JavaScript, dependencies, tracking, storage, or background process.

## Install

Download this repository using **Code → Download ZIP**, then extract it to a permanent folder.

1. Open `chrome://extensions` and enable **Developer mode**.
2. Click **Load unpacked** and choose this folder (unzip first if needed).
3. Refresh your X tabs.

Disable the extension to show these posts again. Keep the installed folder in place.

## Scope

Works on x.com and twitter.com in Chrome 105 or newer. It hides matching articles on timelines and post pages; the separate reply composer remains available. Ordinary posts mentioning paid partnerships stay visible. This targets the supplied paid-partnership disclosure, not every kind of advertisement. If X changes that markup, the selector will need an update. X may temporarily retain blank space in its virtualized timeline until it remeasures the hidden article.

## Verify

With `agent-browser` installed, run `bash test.sh /path/to/chrome-for-testing`. This opens an isolated browser on X, replaces the page body with a local DOM fixture, and tests the installed extension stylesheet. It does not log in or post anything. Use Chrome for Testing because branded Chrome ignores automated extension loading; manual **Load unpacked** works in regular Chrome.

Chrome documentation: https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts
