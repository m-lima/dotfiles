const fetchLandingPage = () => fetch('https://microsoft.github.io/language-server-protocol/specifications/specification-current').then(r => r.text())
const extractActualUrl = (html) => html.match(/<link rel="canonical" href="(.+)">/)[1]
const fecthActualHtml = (url) => fetch(url).then(r => r.text())
const isolateRegionOfInterest = (html) => {
  let section = 0;
  let serverCapabilities = false;
  return html.split('\n').filter(l => {
    if (l.length == 0) {
      return false;
    }
    if (section == 0) {
      if (l.startsWith('<h3 id="language-features">')) {
        section = 1;
      }
      return false;
    } else if (section == 1) {
      if (l.startsWith('<h4 id="miscellaneous">')) {
        section = 2;
        return false;
      }

      if (l.startsWith('<h4 ')) {
        return true;
      }

      if (l === '<p><em>Server Capability</em>:</p>' || l === '<p><em>Request</em>:</p>') {
        serverCapabilities = true;
        return false;
      }

      if (!serverCapabilities) {
        return false;
      }

      if (l === '</ul>') {
        serverCapabilities = false;
        return false;
      }

      return l.startsWith('  <li>property name') || l.startsWith('  <li>method: ');
    } else {
      return false;
    }
  })
}
const trimFat = (sectionList) => sectionList.map(l => l.replace(/<[^>]+>/g, ''))
const print = (methods) => methods.forEach(l => console.log(l))

fetchLandingPage()
  .then(extractActualUrl)
  .then(fecthActualHtml)
  .then(isolateRegionOfInterest)
  .then(trimFat)
  .then(print)
