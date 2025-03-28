import React from 'react';

export const IPhoneIllustration = () => {
  return (
    <div className="device-wrapper">
      <div className="iphone-14-pro">
        {/* Device Frame */}
        <div className="frame">
          {/* Dynamic Island */}
          <div className="dynamic-island"></div>
          
          {/* Screen Content */}
          <div className="screen">
            {/* Empty Status Bar to allow Dynamic Island to blend in */}
            <div className="status-bar"></div>
            
            {/* Sliver App Bar Section with Translucency */}
            <div className="sliver-app-bar">
              <h1>DotCorr Store</h1>
              
              {/* Custom Search Bar (replacing potentially licensed iOS search bar) */}
              <div className="dc-search-bar">
                <div className="dc-search-icon">
                  {/* Custom magnifying glass icon */}
                  <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="5.5" cy="5.5" r="4.5" stroke="currentColor" strokeWidth="1.5"/>
                    <line x1="9" y1="9" x2="13" y2="13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
                  </svg>
                </div>
                <input type="text" placeholder="Search apps and games" readOnly/>
              </div>

              {/* Custom App Banner (replacing potentially licensed app card) */}
              <div className="dc-app-banner">
                <div className="dc-banner-content">
                  <h2>A BOT-anist Adventure</h2>
                  <p>An awe-inspiring tale of a beloved robot on a quest to save extraordinary vegetation from extinction.</p>
                  <div className="dc-action-row">
                    <button className="dc-get-button">Get</button>
                    <div className="dc-rating">★★★★★</div>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Featured Section */}
            <h2 className="section-title">Featured</h2>
            <div className="card-container">
              {/* Card 1 (custom design) */}
              <div className="dc-card">
                <div className="dc-card-image dc-landing-image">
                  <div className="dc-card-gradient"></div>
                  <div className="dc-card-icon"></div>
                </div>
                <div className="dc-card-content">
                  <div className="dc-card-meta">2024 | 4.9★ | Free</div>
                  <div className="dc-card-title">Landing</div>
                  <div className="dc-card-description">After a long journey through</div>
                  <div className="dc-card-tags">
                    <span className="dc-tag">Adventure</span>
                    <span className="dc-tag">Animation</span>
                  </div>
                </div>
              </div>
              
              {/* Card 2 (custom design) */}
              <div className="dc-card">
                <div className="dc-card-image dc-seed-image">
                  <div className="dc-card-gradient"></div>
                  <div className="dc-card-icon"></div>
                </div>
                <div className="dc-card-content">
                  <div className="dc-card-meta">2024 | 4.7★ | Free</div>
                  <div className="dc-card-title">Seed Sampling</div>
                  <div className="dc-card-description">On a planet covered in lush</div>
                  <div className="dc-card-tags">
                    <span className="dc-tag">Animation</span>
                    <span className="dc-tag">Sci-Fi</span>
                  </div>
                </div>
              </div>
              
              {/* Card 3 (custom design) */}
              <div className="dc-card">
                <div className="dc-card-image dc-discovery-image">
                  <div className="dc-card-gradient"></div>
                  <div className="dc-card-icon"></div>
                </div>
                <div className="dc-card-content">
                  <div className="dc-card-meta">2024 | 4.8★ | Free</div>
                  <div className="dc-card-title">Discovery</div>
                  <div className="dc-card-description">The robot makes a startling find</div>
                  <div className="dc-card-tags">
                    <span className="dc-tag">Sci-Fi</span>
                    <span className="dc-tag">Drama</span>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Collections Section */}
            <h2 className="section-title">Collections</h2>
            <div className="collection-container">
              {/* Collection 1 (custom design) */}
              <div className="dc-collection dc-purple-gradient">
                <div className="dc-collection-content">
                  <h3>Robot Series</h3>
                  <p>6 apps</p>
                </div>
                <div className="dc-collection-overlay"></div>
              </div>
              
              {/* Collection 2 (custom design) */}
              <div className="dc-collection dc-green-gradient">
                <div className="dc-collection-content">
                  <h3>Nature & Tech</h3>
                  <p>8 apps</p>
                </div>
                <div className="dc-collection-overlay"></div>
              </div>
            </div>
            
            {/* Custom Tab Bar (replacing potentially licensed design) */}
            <div className="dc-tab-bar">
              <div className="dc-tab dc-active">
                <div className="dc-tab-icon">
                  {/* Custom home icon */}
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M4 10L12 3L20 10V21H4V10Z" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/>
                  </svg>
                </div>
                <div className="dc-tab-label">Today</div>
              </div>
              <div className="dc-tab">
                <div className="dc-tab-icon">
                  {/* Custom games icon */}
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="4" y="4" width="16" height="16" rx="2" stroke="currentColor" strokeWidth="2"/>
                    <line x1="12" y1="8" x2="12" y2="16" stroke="currentColor" strokeWidth="2"/>
                    <line x1="8" y1="12" x2="16" y2="12" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>
                <div className="dc-tab-label">Games</div>
              </div>
              <div className="dc-tab">
                <div className="dc-tab-icon">
                  {/* Custom apps icon */}
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="4" y="4" width="7" height="7" rx="1" stroke="currentColor" strokeWidth="2"/>
                    <rect x="4" y="13" width="7" height="7" rx="1" stroke="currentColor" strokeWidth="2"/>
                    <rect x="13" y="4" width="7" height="7" rx="1" stroke="currentColor" strokeWidth="2"/>
                    <rect x="13" y="13" width="7" height="7" rx="1" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>
                <div className="dc-tab-label">Apps</div>
              </div>
              <div className="dc-tab">
                <div className="dc-tab-icon">
                  {/* Custom arcade icon */}
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="12" cy="12" r="8" stroke="currentColor" strokeWidth="2"/>
                    <rect x="9" y="9" width="6" height="6" rx="3" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>
                <div className="dc-tab-label">Arcade</div>
              </div>
              <div className="dc-tab">
                <div className="dc-tab-icon">
                  {/* Custom search icon */}
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="2"/>
                    <line x1="16" y1="16" x2="20" y2="20" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                  </svg>
                </div>
                <div className="dc-tab-label">Search</div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <style jsx>{`
        /* Theme detection */
        @media (prefers-color-scheme: dark) {
          :root {
            --app-background: #000000;
            --card-background: #1C1C1E;
            --surface-background: #2C2C2E;
            --primary-text: #FFFFFF;
            --secondary-text: #AEAEB2;
            --tertiary-text: #8E8E93;
            --separator-color: rgba(255, 255, 255, 0.1);
            --translucent-background: rgba(20, 20, 20, 0.7);
            --button-background: #0A84FF;
            --tag-background: rgba(255, 255, 255, 0.12);
            --search-background: #1C1C1E;
            --gradient-start: #6A35CE;
            --gradient-end: #231942;
          }
        }
        
        @media (prefers-color-scheme: light) {
          :root {
            --app-background: #F2F2F7;
            --card-background: #FFFFFF;
            --surface-background: #EFEFF4;
            --primary-text: #000000;
            --secondary-text: #3A3A3C;
            --tertiary-text: #8E8E93;
            --separator-color: rgba(0, 0, 0, 0.1);
            --translucent-background: rgba(240, 240, 247, 0.7);
            --button-background: #007AFF;
            --tag-background: rgba(0, 0, 0, 0.05);
            --search-background: #E5E5EA;
            --gradient-start: #8E74DC;
            --gradient-end: #6851A5;
          }
        }
        
        /* Custom device wrapper - original design */
        .device-wrapper {
          width: 390px;
          height: 844px;
          position: relative;
          margin: 0 auto;
        }
        
        .iphone-14-pro {
          width: 100%;
          height: 100%;
          position: relative;
          overflow: hidden;
        }
        
        /* Custom frame - original design */
        .frame {
          width: 390px;
          height: 844px;
          background-color: #1A1A1A;
          border-radius: 60px;
          overflow: hidden;
          position: relative;
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
          border: 10px solid #333;
          box-sizing: border-box;
        }
        
        /* Side buttons - original design */
        .frame::before, .frame::after {
          content: '';
          position: absolute;
          background-color: #333;
          border-radius: 2px;
        }
        
        /* Volume buttons (left side) - original design */
        .frame::before {
          width: 4px;
          height: 60px;
          left: -2px;
          top: 180px;
          box-shadow: 0 80px 0 #333, 0 160px 0 #333;
        }
        
        /* Side button (right side) - original design */
        .frame::after {
          width: 4px;
          height: 100px;
          right: -2px;
          top: 180px;
          box-shadow: 0 -100px 0 #333;
        }
        
        /* Dynamic island - original design */
        .dynamic-island {
          position: absolute;
          top: 12px;
          left: 50%;
          transform: translateX(-50%);
          width: 126px;
          height: 34px;
          background-color: #000;
          border-radius: 20px;
          z-index: 100;
        }
        
        /* Dynamic island inner cutout - original design */
        .dynamic-island::before {
          content: '';
          position: absolute;
          width: 12px;
          height: 12px;
          background-color: #333;
          border-radius: 50%;
          left: 30px;
          top: 11px;
        }
        
        .dynamic-island::after {
          content: '';
          position: absolute;
          width: 8px;
          height: 8px;
          background-color: #555;
          border-radius: 50%;
          right: 40px;
          top: 13px;
        }
        
        /* Screen - original design */
        .screen {
          position: absolute;
          top: 1px;
          left: 1px;
          right: 1px;
          bottom: 1px;
          background-color: var(--app-background);
          border-radius: 50px;
          overflow: hidden;
          padding: 8;
          box-sizing: border-box;
        }
        
        /* Status bar - original design */
        .status-bar {
          height: 44px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          background-color: transparent; 
          z-index: 50;
        }
        
        /* App bar - original design */
        .sliver-app-bar {
          background-color: transparent;
          background-image: linear-gradient(to bottom, 
            var(--translucent-background), 
            rgba(0, 0, 0, 0));
          backdrop-filter: blur(10px);
          -webkit-backdrop-filter: blur(10px);
          padding: 0 16px;
          padding-bottom: 20px;
          position: relative;
          z-index: 5;
        }
        
        .sliver-app-bar h1 {
          color: var(--primary-text);
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
          font-size: 34px;
          font-weight: 700;
          margin: 10px 0 20px;
        }
        
        /* Custom Search Bar - new design to avoid licensing issues */
        .dc-search-bar {
          background-color: var(--search-background);
          border-radius: 10px;
          height: 36px;
          display: flex;
          align-items: center;
          padding: 0 10px;
          margin-bottom: 20px;
        }
        
        .dc-search-icon {
          margin-right: 8px;
          color: var(--tertiary-text);
        }
        
        .dc-search-bar input {
          background: transparent;
          border: none;
          color: var(--primary-text);
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
          font-size: 17px;
          outline: none;
          width: 100%;
        }
        
        .dc-search-bar input::placeholder {
          color: var(--tertiary-text);
        }
        
        /* Custom App Banner - new design to avoid licensing issues */
        .dc-app-banner {
          height: 220px;
          border-radius: 16px;
          overflow: hidden;
          background: linear-gradient(to bottom, var(--gradient-start), var(--gradient-end));
          position: relative;
          padding: 20px;
          margin-bottom: 20px;
        }
        
        .dc-banner-content {
          position: relative;
          z-index: 2;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: flex-end;
        }
        
        .dc-app-banner h2 {
          color: #fff;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
          font-size: 24px;
          margin-bottom: 8px;
        }
        
        .dc-app-banner p {
          color: rgba(255, 255, 255, 0.8);
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
          font-size: 14px;
          margin-bottom: 16px;
          line-height: 1.4;
        }
        
        .dc-action-row {
          display: flex;
          align-items: center;
        }
        
        .dc-get-button {
          background-color: var(--button-background);
          color: #fff;
          border: none;
          border-radius: 18px;
          padding: 6px 20px;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
          font-size: 15px;
          font-weight: 600;
        }
        
        .dc-rating {
          color: #fff;
          margin-left: 15px;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
          font-size: 15px;
        }
        
        /* Section title - original design */
        .section-title {
          color: var(--primary-text);
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
          font-size: 22px;
          margin: 20px 0 15px 16px;
          font-weight: 700;
        }
        
        /* Card container - original design */
        .card-container {
          display: flex;
          padding: 0 16px;
          gap: 14px;
          overflow-x: auto;
          scrollbar-width: none;
          margin-bottom: 20px;
        }
        
        .card-container::-webkit-scrollbar {
          display: none;
        }
        
        /* Custom Card Styling - new design to avoid licensing issues */
        .dc-card {
          width: 155px;
          height: 215px;
          background-color: var(--card-background);
          border-radius: 12px;
          overflow: hidden;
          flex-shrink: 0;
          box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
        }
        
        .dc-card-image {
          height: 120px;
          border-top-left-radius: 12px;
          border-top-right-radius: 12px;
          position: relative;
          overflow: hidden;
        }
        
        /* Custom animated cards with color transitions */
        .dc-card-gradient {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          opacity: 0.7;
          animation: dcColorPulse 8s infinite alternate;
        }
        
        @keyframes dcColorPulse {
          0% { background-color: rgba(106, 53, 206, 0.4); }
          33% { background-color: rgba(45, 20, 98, 0.4); }
          66% { background-color: rgba(0, 127, 95, 0.4); }
          100% { background-color: rgba(85, 166, 48, 0.4); }
        }
        
        /* Staggered timing */
        .dc-card:nth-child(1) .dc-card-gradient { animation-delay: 0s; }
        .dc-card:nth-child(2) .dc-card-gradient { animation-delay: -2s; }
        .dc-card:nth-child(3) .dc-card-gradient { animation-delay: -4s; }
        
        /* Custom background images */
        .dc-landing-image {
          background-color: #1E293B;
          background-image: linear-gradient(45deg, #1E293B 0%, #324c70 100%);
        }
        
        .dc-seed-image {
          background-color: #2D1462;
          background-image: linear-gradient(45deg, #2D1462 0%, #5d2bb5 100%);
        }
        
        .dc-discovery-image {
          background-color: #113537;
          background-image: linear-gradient(45deg, #113537 0%, #1f6e63 100%);
        }
        
        /* Custom card icon animation */
        .dc-card-icon {
          position: absolute;
          width: 50px;
          height: 50px;
          border-radius: 12px;
          left: 25px;
          top: 60px;
          z-index: 2;
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.5);
          animation: dcPulse 3s infinite alternate;
        }
        
        @keyframes dcPulse {
          0% { transform: scale(1); }
          100% { transform: scale(1.1); }
        }
        
        /* Staggered timing */
        .dc-card:nth-child(1) .dc-card-icon { animation-delay: 0s; }
        .dc-card:nth-child(2) .dc-card-icon { animation-delay: -1s; }
        .dc-card:nth-child(3) .dc-card-icon { animation-delay: -2s; }
        
        .dc-landing-image .dc-card-icon {
          background-color: #13407A;
          border: 10px solid #2563EB;
        }
        
        .dc-seed-image .dc-card-icon {
          background-color: #3A1772;
          border: 10px solid #7B4AE2;
        }
        
        .dc-discovery-image .dc-card-icon {
          background-color: #0F5C54;
          border: 10px solid #14B8A6;
        }
        
        /* Custom card content */
        .dc-card-content {
          padding: 12px;
        }
        
        .dc-card-meta {
          color: var(--tertiary-text);
          font-size: 12px;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
          margin-bottom: 4px;
        }
        
        .dc-card-title {
          color: var(--primary-text);
          font-size: 16px;
          font-weight: bold;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
          margin-bottom: 4px;
        }
        
        .dc-card-description {
          color: var(--secondary-text);
          font-size: 12px;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
          margin-bottom: 8px;
        }
        
        .dc-card-tags {
          display: flex;
          gap: 5px;
          flex-wrap: wrap;
        }
        
        .dc-tag {
          background-color: var(--tag-background);
          color: var(--secondary-text);
          font-size: 11px;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
          padding: 4px 8px;
          border-radius: 11px;
        }
        
        /* Custom Collections - new design to avoid licensing issues */
        .collection-container {
          display: flex;
          padding: 0 16px;
          gap: 14px;
          margin-bottom: 83px; /* Increased to match tab bar height */
        }
        
        .dc-collection {
          width: 155px;
          height: 110px;
          border-radius: 12px;
          position: relative;
          overflow: hidden;
          box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
        }
        
        .dc-collection-content {
          position: absolute;
          bottom: 0;
          left: 0;
          padding: 12px;
          z-index: 2;
        }
        
        .dc-collection-content h3 {
          color: #fff;
          font-size: 16px;
          font-weight: bold;
          margin: 0 0 4px 0;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
        }
        
        .dc-collection-content p {
          color: rgba(255, 255, 255, 0.8);
          font-size: 12px;
          margin: 0;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
        }
        
        /* Custom gradients */
        .dc-purple-gradient {
          background: linear-gradient(135deg, #8751D8 0%, #231942 100%);
          background-size: 200% 200%;
          animation: dcGradientShift1 10s infinite alternate;
        }
        
        .dc-green-gradient {
          background: linear-gradient(135deg, #007F5F 0%, #55A630 100%);
          background-size: 200% 200%;
          animation: dcGradientShift2 10s infinite alternate;
        }
        
        @keyframes dcGradientShift1 {
          0% { background-position: 0% 50%; }
          100% { background-position: 100% 50%; }
        }
        
        @keyframes dcGradientShift2 {
          0% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
        
        .dc-collection-overlay {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: linear-gradient(to top, rgba(0, 0, 0, 0.8) 0%, rgba(0, 0, 0, 0) 60%);
        }
        
        /* Custom Tab Bar - new design to avoid licensing issues */
        .dc-tab-bar {
          position: absolute;
          bottom: 0;
          left: 0;
          right: 0;
          height: 83px;
          display: flex;
          justify-content: space-around;
          align-items: center;
          border-top: 1px solid var(--separator-color);
          background-color: var(--translucent-background);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          z-index: 100;
          padding-bottom: 20px;
        }
        
        /* Home indicator */
        .dc-tab-bar::after {
          content: '';
          position: absolute;
          bottom: 8px;
          left: 50%;
          transform: translateX(-50%);
          width: 134px;
          height: 5px;
          background-color: var(--primary-text);
          border-radius: 3px;
          opacity: 0.3;
        }
        
        .dc-tab {
          display: flex;
          flex-direction: column;
          align-items: center;
          width: 20%;
        }
        
        .dc-tab-icon {
          width: 28px;
          height: 28px;
          margin-bottom: 4px;
          display: flex;
          justify-content: center;
          align-items: center;
          color: var(--tertiary-text);
        }
        
        .dc-tab-icon svg {
          width: 24px;
          height: 24px;
        }
        
        .dc-tab-label {
          color: var(--tertiary-text);
          font-size: 10px;
          font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
        }
        
        .dc-tab.dc-active .dc-tab-label {
          color: var(--button-background);
        }
        
        .dc-tab.dc-active .dc-tab-icon {
          color: var(--button-background);
        }
      `}</style>
    </div>
  );
};

export default IPhoneIllustration;