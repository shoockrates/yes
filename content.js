chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.action === 'scroll') {
      smoothScroll(message.direction);
    }
  });
  
  function smoothScroll(direction) {
    const step = 25;
    window.scrollBy({
      top: step * direction,
      behavior: 'auto' // smooth
    });
  }