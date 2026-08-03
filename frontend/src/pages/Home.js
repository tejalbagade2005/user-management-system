import React from 'react';

export default function Home() {
  return (
    <div className="container page-section">
      <section className="hero">
        <h1>Premium FullStack Dashboard</h1>
        <p>Experience a refined React + Spring Boot + MySQL application with modern authentication and polished visual design.</p>
      </section>
      <section className="row-grid grid-3">
        <div className="card-panel">
          <h2>Secure Auth</h2>
          <p>JWT-based login flow with token management for protected app access.</p>
        </div>
        <div className="card-panel">
          <h2>Responsive UI</h2>
          <p>A premium glassmorphism theme with smooth page transitions and mobile-friendly layout.</p>
        </div>
        <div className="card-panel">
          <h2>Fast Backend</h2>
          <p>Spring Boot services integrated with MySQL for reliable data handling and user management.</p>
        </div>
      </section>
    </div>
  );
}
