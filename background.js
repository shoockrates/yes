chrome.commands.onCommand.addListener(async (command) => {
    try {
      if (command === 'move-tab-left' || command === 'move-tab-right') {
        const [currentTab] = await chrome.tabs.query({ active: true, currentWindow: true });
        const allTabs = await chrome.tabs.query({ currentWindow: true });
        
        const currentIndex = currentTab.index;
        const lastTabIndex = allTabs.length - 1;
        
        if (command === 'move-tab-left') {
          const newIndex = currentIndex > 0 ? currentIndex - 1 : lastTabIndex;
          const prevTab = allTabs.find(tab => tab.index === newIndex);
          if (prevTab) await chrome.tabs.update(prevTab.id, { active: true });
        } 
        else if (command === 'move-tab-right') {
          const newIndex = currentIndex < lastTabIndex ? currentIndex + 1 : 0;
          const nextTab = allTabs.find(tab => tab.index === newIndex);
          if (nextTab) await chrome.tabs.update(nextTab.id, { active: true });
        }
      }
      else if (command === 'scroll-down' || command === 'scroll-up') {
        const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
        
        if (tab.url && tab.url.startsWith('http')) {
          await chrome.tabs.sendMessage(tab.id, { 
            action: 'scroll',
            direction: command === 'scroll-down' ? 1 : -1
          });
        }
      }
    } catch (err) {
      console.error("Command failed:", command, err);
    }
  });