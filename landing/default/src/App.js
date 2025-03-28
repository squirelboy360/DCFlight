import React, { useEffect } from 'react';
import { AndroidIllustration } from './COMPS/android/android-illu';
import { IPhoneIllustration } from './COMPS/iphone/iphone-illu';
import { DesktopIllustration } from './COMPS/web/desktop-illu';

const App = () => {
  useEffect(() => {
    // Card animation and interaction script
    const cards = document.querySelectorAll('.card');
    
    cards.forEach(card => {
      card.addEventListener('mouseover', function() {
        this.style.animationPlayState = 'paused';
      });
      
      card.addEventListener('mouseout', function() {
        this.style.animationPlayState = 'running';
      });
    });
    
    // Reset typing animation 
    const resetTyping = () => {
      const typingElements = document.querySelectorAll('.typing');
      typingElements.forEach(el => {
        el.classList.remove('typing');
        void el.offsetWidth; // Trigger reflow
        el.classList.add('typing');
      });
    };
    
    const interval = setInterval(resetTyping, 8000);
    return () => clearInterval(interval);
  }, []);

  return (
    <>
      <header>
        <div className="logo">Dotcorr</div>
        <p className="tagline">A suite of development tools designed to make developers' lives easier</p>
      </header>

      <div className="container">
        <div className="intro">
          <p>Dotcorr provides a comprehensive toolkit that streamlines application development, deployment, and maintenance. Our open-source tools are designed by developers, for developers, to solve real-world problems in modern software development.</p>
        </div>
        
        <h2>Our Development Tools</h2>
        
        <div className="cards">
          <div id="maui-card" className="card float-animation" onClick={() => window.open('http://dotcorr.maui.com', '_blank')}>
            <div className="card-inner">
              <div className="card-icon">
                <i className="fas fa-mobile-alt"></i> <i className="fas fa-laptop"></i> <i className="fas fa-desktop"></i>
              </div>
              
              <div className="platform-grid">
                {platforms.map((platform, index) => (
                  <div key={index} className="platform-item">
                    <div className="platform-icon"><i className={platform.icon}></i></div>
                    <div className="platform-name">{platform.name}</div>
                  </div>
                ))}
              </div>
              
              <h3 className="card-title">Dotcorr Maui</h3>
              <p className="card-description">Build native cross-platform apps with a single codebase</p>
              
              <div className="code-sample">
                <div className="typing">
                  import 'package:dotcorr/ui_composer.dart';
                </div>
              </div>
              
              <a href="http://dotcorr.maui.com" className="btn">Explore Maui</a>
            </div>
          </div>
          
          <div id="voltron-card" className="card float-animation" onClick={() => window.open('http://dotcorr.voltron.com', '_blank')}>
            {/* Voltron card content similar to Maui card */}
          </div>
        </div>
        
        <div className="features">
          {features.map((feature, index) => (
            <div key={index} className="feature">
              <div className="feature-icon">
                <i className={feature.icon}></i>
              </div>
              <h3 className="feature-title">{feature.title}</h3>
              <p className="feature-description">{feature.description}</p>
            </div>
          ))}
        </div>

        <div className="device-showcase">
          <IPhoneIllustration />
          <AndroidIllustration />
          <DesktopIllustration />
        </div>
      </div>
      
      <footer>
        <p className="footer-text">© 2025 Dotcorr. All rights reserved. Open-source tools for developers.</p>
        <div className="footer-links">
          <a href="#" className="footer-link">Documentation</a>
          <a href="#" className="footer-link">GitHub</a>
          <a href="#" className="footer-link">Community</a>
          <a href="#" className="footer-link">Contact</a>
        </div>
      </footer>
    </>
  );
};

const platforms = [
  { icon: 'fab fa-android', name: 'Android' },
  { icon: 'fab fa-apple', name: 'iOS' },
  { icon: 'fab fa-windows', name: 'Windows' },
  { icon: 'fab fa-linux', name: 'Linux' },
  { icon: 'fab fa-apple', name: 'macOS' },
  { icon: 'fas fa-globe', name: 'Web' },
];

const features = [
  {
    icon: 'fas fa-rocket',
    title: 'Accelerate Development',
    description: 'Build once, deploy everywhere with our cross-platform tools and hot-reload capabilities.'
  },
  {
    icon: 'fas fa-code',
    title: 'Developer-First Design', 
    description: 'Created by developers who understand real-world challenges, our tools integrate seamlessly.'
  },
  {
    icon: 'fas fa-shield-alt',
    title: 'Enterprise Ready',
    description: 'Built with security and scalability in mind for mission-critical applications.'
  },
  {
    icon: 'fas fa-handshake',
    title: 'Open Source Community',
    description: 'Join our thriving community. Contribute and collaborate to make Dotcorr even better.'
  }
];

export default App;
