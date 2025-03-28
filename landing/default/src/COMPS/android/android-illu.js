import React from 'react';

export const AndroidIllustration = () => {
  return (
    <div className="relative w-[360px] h-[780px] mx-auto p-2.5">
      <div className="w-full h-full relative">
        {/* Device Frame */}
        <div className="w-full h-full bg-device-frame rounded-[30px] overflow-hidden relative shadow-2xl border-[8px] border-device-border">
          
          {/* Screen Content */}
          <div className="absolute inset-[1px] bg-white dark:bg-black overflow-hidden">
            {/* Status Bar */}
            <div className="h-6 bg-primary flex justify-between items-center px-4 text-white">
              <div className="flex gap-2">
                <div className="w-3.5 h-3.5 bg-white/80 clip-path-battery"></div>
                <div className="w-3.5 h-3.5 bg-white/80 clip-path-wifi"></div>
                <div className="w-3.5 h-3.5 bg-white/80 clip-path-signal"></div>
              </div>
              <div className="text-sm font-medium">9:41</div>
            </div>

            {/* Material App Bar */}
            <div className="bg-primary p-4 text-white shadow">
              <h1 className="text-xl font-medium mb-4">DotCorr Store</h1>
              
              {/* Search Bar */}
              <div className="flex items-center h-12 bg-white/15 rounded px-4 mb-4">
                <svg className="w-5 h-5 text-white/90" viewBox="0 0 24 24">
                  <path d="M15.5 14H14.71L14.43 13.73C15.41 12.59 16 11.11 16 9.5C16 5.91 13.09 3 9.5 3C5.91 3 3 5.91 3 9.5C3 13.09 5.91 16 9.5 16C11.11 16 12.59 15.41 13.73 14.43L14 14.71V15.5L19 20.49L20.49 19L15.5 14ZM9.5 14C7.01 14 5 11.99 5 9.5C5 7.01 7.01 5 9.5 5C11.99 5 14 7.01 14 9.5C14 11.99 11.99 14 9.5 14Z" fill="currentColor"/>
                </svg>
                <input 
                  type="text"
                  placeholder="Search apps & games"
                  className="bg-transparent border-none text-white placeholder-white/70 text-base ml-3 w-full outline-none"
                  readOnly
                />
              </div>

              {/* Featured Banner */}
              <div className="rounded-lg overflow-hidden bg-gradient-to-br from-purple-600 to-purple-900 p-5">
                <div className="dc-banner-content">
                  <h2 className="text-lg font-medium mb-2">A BOT-anist Adventure</h2>
                  <p className="text-sm mb-4">An awe-inspiring tale of a beloved robot on a quest to save extraordinary vegetation from extinction.</p>
                  <div className="flex items-center gap-2">
                    <button className="bg-white text-primary px-4 py-2 rounded">Get</button>
                    <div className="text-yellow-400">★★★★★</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Featured Apps */}
            <h2 className="text-lg font-medium px-4 mt-6 mb-4 dark:text-white">Featured</h2>
            <div className="flex overflow-x-auto px-4 gap-3.5 hide-scrollbar pb-4">
              {[
                {
                  image: 'landing',
                  meta: '2024 | 4.9★ | Free',
                  title: 'Landing',
                  desc: 'After a long journey through',
                  tags: ['Adventure', 'Animation']
                },
                {
                  image: 'seed',
                  meta: '2024 | 4.7★ | Free', 
                  title: 'Seed Sampling',
                  desc: 'On a planet covered in lush',
                  tags: ['Animation', 'Sci-Fi']
                },
                {
                  image: 'discovery',
                  meta: '2024 | 4.8★ | Free',
                  title: 'Discovery', 
                  desc: 'The robot makes a startling find',
                  tags: ['Sci-Fi', 'Drama']
                }
              ].map((card, i) => (
                <div key={i} className="min-w-[200px] bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden">
                  <div className={`h-32 bg-cover bg-center ${card.image}-image`}>
                    <div className="h-full w-full bg-gradient-to-t from-black/70 to-transparent"></div>
                  </div>
                  <div className="p-4">
                    <div className="text-xs text-gray-500 mb-1">{card.meta}</div>
                    <div className="text-sm font-medium mb-1">{card.title}</div>
                    <div className="text-xs text-gray-500 mb-2">{card.desc}</div>
                    <div className="flex gap-1">
                      {card.tags.map((tag, j) => (
                        <span key={j} className="text-xs bg-gray-200 dark:bg-gray-700 rounded-full px-2 py-1">{tag}</span>
                      ))}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Collections */}
            <h2 className="text-lg font-medium px-4 mt-6 mb-4 dark:text-white">Collections</h2>
            <div className="flex px-4 gap-3.5 mb-20">
              {[
                { gradient: 'purple', title: 'Robot Series', count: 6 },
                { gradient: 'green', title: 'Nature & Tech', count: 8 }
              ].map((collection, i) => (
                <div key={i} className={`min-w-[150px] h-32 bg-gradient-to-br from-${collection.gradient}-600 to-${collection.gradient}-900 rounded-lg overflow-hidden relative`}>
                  <div className="absolute inset-0 bg-black/30"></div>
                  <div className="relative p-4">
                    <h3 className="text-sm font-medium text-white mb-1">{collection.title}</h3>
                    <p className="text-xs text-white">{collection.count} apps</p>
                  </div>
                </div>
              ))}
            </div>

            {/* Bottom Navigation */}
            <div className="fixed bottom-0 left-0 right-0 h-14 bg-white dark:bg-gray-900 flex justify-around items-center shadow-up">
              {[
                { icon: 'home', label: 'Today', active: true },
                { icon: 'games', label: 'Games' },
                { icon: 'apps', label: 'Apps' },
                { icon: 'arcade', label: 'Arcade' },
                { icon: 'search', label: 'Search' }
              ].map((item, i) => (
                <div key={i} className={`flex flex-col items-center ${item.active ? 'text-primary' : 'text-gray-500'}`}>
                  <div className="w-6 h-6 mb-1">
                    {/* ...SVG icons from template... */}
                  </div>
                  <div className="text-xs">{item.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Side Buttons */}
        <div className="absolute -right-0.5 top-[120px] w-1 h-[60px] bg-device-border rounded-l"></div>
        <div className="absolute -left-0.5 top-[140px] w-1 h-[100px] bg-device-border rounded-r"></div>
      </div>
    </div>
  );
};

export default AndroidIllustration;
