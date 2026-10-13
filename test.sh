#!/usr/bin/env bash
set -euo pipefail
extension_dir="$(cd "$(dirname "$0")" && pwd)"
session="partnership-check-$$"
trap 'agent-browser --session "$session" close >/dev/null 2>&1 || true' EXIT
# Supply a Chrome for Testing executable; branded Chrome ignores --load-extension.
: "${1:?Usage: bash test.sh /path/to/chrome-for-testing}"
agent-browser --session "$session" --executable-path "$1" --extension "$extension_dir" open https://x.com/home
agent-browser --session "$session" eval --stdin <<'JS'
(() => {
  const policy = 'https://help.x.com/rules-and-policies/paid-partnerships-policy';
  const label = `<div><a href="${policy}" role="link"><svg></svg><span> </span><span>Paid partnership</span></a></div>`;
  document.body.innerHTML = `
    <h1>Paid partnership blocker check</h1>
    <article id="normal" data-testid="tweet"><div data-testid="tweetText">Ordinary post</div></article>
    <div data-testid="cellInnerDiv">
      <article id="paid" data-testid="tweet"><div data-testid="tweetText">Sponsored post</div>${label}</article>
      <div id="composer" contenteditable="true">Reply composer stays visible</div>
    </div>
    <article id="mention" data-testid="tweet"><div data-testid="tweetText">Let's discuss Paid partnership labels</div></article>
    <article id="body-link" data-testid="tweet"><div data-testid="tweetText"><a href="${policy}">Policy discussion</a></div></article>
    <aside id="outside">${label}</aside>`;
  const passed = [];
  function check(id, hidden, name) {
    const actual = getComputedStyle(document.getElementById(id)).display === 'none';
    if (actual !== hidden) throw new Error(name);
    passed.push(name);
  }
  check('paid', true, 'Disclosure hides the article');
  for (const id of ['normal', 'composer', 'mention', 'body-link', 'outside']) {
    check(id, false, `${id} remains visible`);
  }
  document.getElementById('normal').insertAdjacentHTML('beforeend', label);
  check('normal', true, 'Late disclosure hides an existing post');
  document.getElementById('normal').lastElementChild.remove();
  check('normal', false, 'Removing the disclosure restores a recycled post');
  document.body.insertAdjacentHTML('beforeend', `<article id="dynamic" data-testid="tweet">New post${label}</article>`);
  check('dynamic', true, 'Newly inserted sponsored post is hidden');
  document.getElementById('dynamic').querySelector('a').href = 'https://example.com';
  check('dynamic', false, 'Changing the link restores visibility');
  document.getElementById('dynamic').remove();
  const start = performance.now();
  const batch = document.createElement('section');
  batch.innerHTML = Array.from({length: 500}, (_, i) => `<article data-testid="tweet">Post ${i}${i % 2 ? label : ''}</article>`).join('');
  document.body.append(batch);
  const hidden = [...batch.children].filter(node => getComputedStyle(node).display === 'none').length;
  if (hidden !== 250) throw new Error(`Batch: expected 250 hidden, got ${hidden}`);
  const batchMs = Math.round(performance.now() - start);
  batch.remove();
  passed.push('500-post batch: exactly the 250 disclosures hidden');
  return {passed, batchMs, browser: navigator.userAgent};
})()
JS
