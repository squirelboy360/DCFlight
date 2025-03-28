import React from 'react';

export const DesktopIllustration = () => {
  return (
    <div className="relative w-[1024px] h-[640px] mx-auto p-2.5">
      <div className="w-full h-full bg-[#1a1a1a] dark:bg-black rounded-xl overflow-hidden shadow-2xl border border-[#333333] dark:border-gray-800">
        {/* Browser Chrome */}
        <div className="h-10 bg-[#2D2D2D] dark:bg-gray-900 flex items-center px-3 border-b border-[#333333]">
          {/* Window Controls */}
          <div className="flex gap-2 mr-4">
            <div className="w-3 h-3 rounded-full bg-[#ff5f56]"></div>
            <div className="w-3 h-3 rounded-full bg-[#ffbd2e]"></div>
            <div className="w-3 h-3 rounded-full bg-[#27c93f]"></div>
          </div>
          
          {/* Address Bar */}
          <div className="flex-1 h-7 bg-[#1A1A1A] dark:bg-black rounded flex items-center px-3 text-white text-sm">
            <svg className="w-4 h-4 text-green-500 mr-2" viewBox="0 0 24 24">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" fill="none" stroke="currentColor" strokeWidth="2"/>
            </svg>
            dotcorr.app/store
          </div>
        </div>

        {/* Main Content */}
        <div className="h-[calc(100%-2.5rem)] bg-white dark:bg-gray-900 overflow-auto">
          {/* Store Header */}
          <header className="sticky top-0 z-10 bg-white/80 dark:bg-gray-900/80 backdrop-blur-lg border-b border-gray-200 dark:border-gray-800">
            <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
              <div className="text-xl font-semibold dark:text-white">DotCorr Store</div>
              
              <nav className="flex gap-8">
                {['Store', 'Categories', 'Collections', 'Search'].map((item, i) => (
                  <a 
                    key={i}
                    href="#"
                    className={`text-sm ${i === 0 
                      ? 'text-indigo-600 dark:text-indigo-400' 
                      : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white'
                    }`}
                  >
                    {item}
                  </a>
                ))}
              </nav>

              <div className="flex items-center gap-4">
                <button className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 dark:hover:bg-gray-800">
                  <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none">
                    <path d="M12 16C14.2091 16 16 14.2091 16 12C16 9.79086 14.2091 8 12 8C9.79086 8 8 9.79086 8 12C8 14.2091 9.79086 16 12 16Z" stroke="currentColor" strokeWidth="2"/>
                    <path d="M12 2V4M12 20V22M4 12H2M6.31412 6.31412L4.8999 4.8999M17.6859 6.31412L19.1001 4.8999M6.31412 17.69L4.8999 19.1042M17.6859 17.69L19.1001 19.1042M22 12H20" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                  </svg>
                </button>
                <button className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 dark:hover:bg-gray-800">
                  <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/>
                    <path d="M5 20C5 17.2386 8.13401 15 12 15C15.866 15 19 17.2386 19 20" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </button>
              </div>
            </div>
          </header>

          {/* Hero Banner */}
          <div className="px-4 py-8">
            <div className="max-w-7xl mx-auto">
              <div className="rounded-2xl overflow-hidden bg-gradient-to-br from-purple-600 to-indigo-900 p-8">
                <div className="max-w-2xl">
                  <h2 className="text-3xl font-bold text-white mb-4">A BOT-anist Adventure</h2>
                  <p className="text-white/80 text-lg mb-6">
                    An awe-inspiring tale of a beloved robot on a quest to save extraordinary vegetation from extinction.
                  </p>
                  <div className="flex items-center gap-4">
                    <button className="bg-white text-indigo-900 px-6 py-2 rounded-lg font-semibold">
                      Get
                    </button>
                    <div className="text-white text-xl">★★★★★</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Featured Section */}
          <div className="px-4 py-6">
            <div className="max-w-7xl mx-auto">
              <h2 className="text-2xl font-bold mb-6 dark:text-white">Featured</h2>
              <div className="grid grid-cols-3 gap-6">
                {[
                  {
                    image: 'landing',
                    meta: '2024 | 4.9★ | Free',
                    title: 'Landing',
                    desc: 'After a long journey through space...',
                    tags: ['Adventure', 'Animation']
                  },
                  {
                    image: 'seed',
                    meta: '2024 | 4.7★ | Free',
                    title: 'Seed Sampling',
                    desc: 'On a planet covered in lush forests...',
                    tags: ['Animation', 'Sci-Fi']
                  },
                  {
                    image: 'discovery',
                    meta: '2024 | 4.8★ | Free',
                    title: 'Discovery',
                    desc: 'The robot makes a startling find...',
                    tags: ['Sci-Fi', 'Drama']
                  }
                ].map((card, i) => (
                  <div key={i} className="bg-white dark:bg-gray-800 rounded-xl overflow-hidden shadow-lg">
                    <div className={`h-48 bg-gradient-to-br ${
                      i === 0 ? 'from-blue-600 to-blue-900' :
                      i === 1 ? 'from-purple-600 to-purple-900' :
                      'from-green-600 to-green-900'
                    } relative`}>
                      <div className="absolute inset-0 bg-black/20"></div>
                    </div>
                    <div className="p-6">
                      <div className="text-sm text-gray-500 dark:text-gray-400 mb-2">{card.meta}</div>
                      <h3 className="text-xl font-semibold mb-2 dark:text-white">{card.title}</h3>
                      <p className="text-gray-600 dark:text-gray-300 mb-4">{card.desc}</p>
                      <div className="flex gap-2">
                        {card.tags.map((tag, j) => (
                          <span key={j} className="px-3 py-1 bg-gray-100 dark:bg-gray-700 rounded-full text-sm">
                            {tag}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Collections Section */}
          <div className="px-4 py-6">
            <div className="max-w-7xl mx-auto">
              <h2 className="text-2xl font-bold mb-6 dark:text-white">Collections</h2>
              <div className="grid grid-cols-2 gap-6">
                {[
                  { title: 'Robot Series', count: 6, gradient: 'from-purple-600 to-purple-900' },
                  { title: 'Nature & Tech', count: 8, gradient: 'from-green-600 to-green-900' }
                ].map((collection, i) => (
                  <div key={i} className={`rounded-xl overflow-hidden bg-gradient-to-br ${collection.gradient} h-48 relative`}>
                    <div className="absolute inset-0 bg-black/20"></div>
                    <div className="absolute bottom-0 left-0 p-6">
                      <h3 className="text-2xl font-bold text-white mb-2">{collection.title}</h3>
                      <p className="text-white/80">{collection.count} apps</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DesktopIllustration;
