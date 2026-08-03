import React, {useState, useEffect} from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../services/authService';

export default function Login({onLogin}){
  const navigate = useNavigate();
  const [form, setForm] = useState({username:'', password:'', remember:false});
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  // Redirect to dashboard if already logged in
  useEffect(() => {
    if (authService.isLoggedIn()) {
      navigate('/dashboard', { replace: true });
    }
  }, [navigate]);

  const handle = e => {
    const {name, value, type, checked} = e.target;
    setForm({...form, [name]: type==='checkbox'?checked:value});
  }

  const submit = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    
    try {
      const res = await authService.login({username: form.username, password: form.password});
      const token = res.data.token;
      const user = res.data.user;
      
      // Store auth data
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
      localStorage.setItem('username', user.username);
      
      // Callback if provided
      onLogin && onLogin();
      
      // Navigate to dashboard
      navigate('/dashboard', { replace: true });
    } catch (err) {
      const errorMessage = err.response?.data?.error || err.message || 'Login failed';
      setError(errorMessage);
      console.error('Login error:', err);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container page-section">
      <section className="form-panel">
        <div className="page-heading">
          <div>
            <h2>Sign in</h2>
            <p className="cta-note">Access your dashboard with secure credentials.</p>
          </div>
        </div>
        {error && <div className="alert" style={{color: 'red', padding: '10px', backgroundColor: '#ffe0e0', borderRadius: '4px', marginBottom: '1rem'}}>{error}</div>}
        <form onSubmit={submit}>
          <div className="form-group">
            <label htmlFor="username">Username or email</label>
            <input id="username" name="username" value={form.username} onChange={handle} placeholder="Enter username or email" required disabled={loading} />
          </div>
          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input id="password" name="password" type="password" value={form.password} onChange={handle} placeholder="Enter your password" required disabled={loading} />
          </div>
          <div className="form-group" style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <input id="remember" name="remember" type="checkbox" checked={form.remember} onChange={handle} style={{ width: '1rem', height: '1rem' }} disabled={loading} />
            <label htmlFor="remember">Remember me</label>
          </div>
          <button className="btn-primary" type="submit" disabled={loading}>{loading ? 'Logging in...' : 'Login'}</button>
        </form>
      </section>
    </div>
  )
}
