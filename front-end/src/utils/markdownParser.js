const rules = [
  [/#{6}\s?([^\n]+)\n/gm, "<h6>$1</h6>"],
  [/#{5}\s?([^\n]+)\n/gm, "<h5>$1</h5>"],
  [/#{4}\s?([^\n]+)\n/gm, "<h4>$1</h4>"],
  [/#{3}\s?([^\n]+)\n/gm, "<h3>$1</h3>"],
  [/#{2}\s?([^\n]+)\n/gm, "<h2>$1</h2>"],
  [/#{1}\s?([^\n]+)\n/gm, "<h1>$1</h1>"],
  //eslint-disable-next-line
  [/\*\*([^\*]+)\*\*/gm, "<b>$1</b>"],
  //eslint-disable-next-line
  [/\*([^\*]+)\*/gm, "<i>$1</i>"],
  //eslint-disable-next-line
  // [/((\n\d\..+)+)/gm, "<ol>$1</ol>"],
  [/((\n\*.+)+)/gm, "<ul>$1</ul>"],

  //eslint-disable-next-line
  [/[\-|*|+]{1}\s{1}(.*?)\n/gm, "<li>$1</li>"],
  //eslint-disable-next-line
  [/\n[\*\.\+]([^\n]+)/gm, "<li>$1</li>"],
  //eslint-disable-next-line
  [/\!\[(.*)\]\((.*)\)/gm, "<img alt='$1' src='$2'>"],
  [/\[(.*)\]\((.*)\)/gm, "<a href='$2'>$1</a>"],

  //eslint-disable-next-line
  [/([^\n]+)\n/gm, "<p>$1</p>"]
];

export default {
  convertMarkdown(text) {
    if (text) {
      for (let [rule, template] of rules) {
        text = text.replace(rule, template);
      }
    }

    return text;
  }
};
