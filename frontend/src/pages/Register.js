import React, {useState} from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

export default function Register() {
  const navigate = useNavigate();
  const [form, setForm] = useState({fullName:'', email:'', mobile:'', username:'', password:'', confirmPassword:''});
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [loading, setLoading] = useState(false);

  const handle = e => setForm({...form, [e.target.name]: e.target.value});

  const submit = async (e) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setLoading(true);

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!form.fullName.trim()) {
      setError('Full Name is required');
      setLoading(false);
      return;
    }
    if (!emailRegex.test(form.email)) {
      setError('Invalid email format');
      setLoading(false);
      return;
    }
    if (!form.username.trim()) {
      setError('Username is required');
      setLoading(false);
      return;
    }
    if (form.password.length < 8) {
      setError('Password must be at least 8 characters');
      setLoading(false);
      return;
    }
    if (form.password !== form.confirmPassword) {
      setError('Passwords do not match');
      setLoading(false);
      return;
    }

    const apiBaseUrl = process.env.REACT_APP_API_URL || 'https://user-management-system-5ms2.onrender.com/api';
    const requestPayload = {
      fullName: form.fullName,
      email: form.email,
      mobile: form.mobile,
      username: form.username,
      password: form.password
    };

    console.log('Register submit -> API URL:', `${apiBaseUrl}/auth/register`);
    console.log('Register submit -> payload:', requestPayload);

    try {
      const response = await axios.post(`${apiBaseUrl}/auth/register`, requestPayload, {
        headers: {
          'Content-Type': 'application/json'
        },
        withCredentials: true
      });

      console.log('Register success response:', response);
      setSuccess('Registration successful. Redirecting to login...');
      setTimeout(() => navigate('/login', { replace: true }), 800);
    } catch (err) {
      console.error('Register network error:', err);
      console.error('Register error response data:', err.response?.data);
      console.error('Register error status:', err.response?.status);
      const errorMessage = err.response?.data?.error || err.response?.data?.message || err.message || 'Registration failed';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container page-section">
      <section className="form-panel">
        <div className="page-heading">
          <h2>Create your account</h2>
          <p className="cta-note">Secure access with a modern auth flow.</p>
        </div>
        {error && <div className="alert" style={{color: 'red', padding: '10px', backgroundColor: '#ffe0e0', borderRadius: '4px', marginBottom: '1rem'}}>{error}</div>}
        {success && <div className="alert" style={{color: 'green', padding: '10px', backgroundColor: '#e8f7ed', borderRadius: '4px', marginBottom: '1rem'}}>{success}</div>}
        <form onSubmit={submit}>
          <div className="form-group">
            <label htmlFor="fullName">Full name</label>
            <input id="fullName" name="fullName" value={form.fullName} onChange={handle} placeholder="Enter your name" required disabled={loading} />
          </div>
          <div className="form-group">
            <label htmlFor="email">Email address</label>
            <input id="email" name="email" type="email" value={form.email} onChange={handle} placeholder="you@example.com" required disabled={loading} />
          </div>
          <div className="form-group">
            <label htmlFor="mobile">Mobile number</label>
            <input id="mobile" name="mobile" value={form.mobile} onChange={handle} placeholder="Optional" disabled={loading} />
          </div>
          <div className="form-group">
            <label htmlFor="username">Username</label>
            <input id="username" name="username" value={form.username} onChange={handle} placeholder="Choose a username" required disabled={loading} />
          </div>
          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input id="password" name="password" type="password" value={form.password} onChange={handle} placeholder="Create a password" required disabled={loading} />
          </div>
          <div className="form-group">
            <label htmlFor="confirmPassword">Confirm password</label>
            <input id="confirmPassword" name="confirmPassword" type="password" value={form.confirmPassword} onChange={handle} placeholder="Re-enter password" required disabled={loading} />
          </div>
          <button className="btn-primary" type="submit" disabled={loading}>{loading ? 'Registering...' : 'Register'}</button>
        </form>
      </section>
    </div>
  )
}
