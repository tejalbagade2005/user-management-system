import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import authService from '../services/authService';

const PAGE_SIZE = 10;

export default function Dashboard() {
  const navigate = useNavigate();
  const username = localStorage.getItem('username') || 'User';
  const [users, setUsers] = useState([]);
  const [stats, setStats] = useState({ totalUsers: 0, activeUsers: 0, newUsersToday: 0 });
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [page, setPage] = useState(1);

  const fetchUsers = useCallback(async () => {
    try {
      const response = await api.get('/users', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token') || ''}`,
        },
      });
      const payload = response.data || {};
      const fetchedUsers = Array.isArray(payload.users) ? payload.users : [];
      setUsers(fetchedUsers);
      setStats({
        totalUsers: payload.totalUsers ?? fetchedUsers.length,
        activeUsers: payload.activeUsers ?? 0,
        newUsersToday: payload.newUsersToday ?? 0,
      });
      setError('');
    } catch (err) {
      console.error('Failed to load users', err);
      setError('Unable to load user data right now.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (!authService.isLoggedIn()) {
      navigate('/login', { replace: true });
      return;
    }

    fetchUsers();
    const intervalId = window.setInterval(() => {
      fetchUsers();
    }, 5000);

    return () => window.clearInterval(intervalId);
  }, [fetchUsers, navigate]);

  useEffect(() => {
    setPage(1);
  }, [search]);

  const filteredUsers = useMemo(() => {
    const query = search.trim().toLowerCase();
    if (!query) {
      return users;
    }

    return users.filter((user) => {
      const haystacks = [user.fullName, user.username, user.email].filter(Boolean).join(' ').toLowerCase();
      return haystacks.includes(query);
    });
  }, [search, users]);

  const totalPages = Math.max(1, Math.ceil(filteredUsers.length / PAGE_SIZE));
  const paginatedUsers = filteredUsers.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleLogout = useCallback(async () => {
    try {
      await authService.logout();
    } catch (err) {
      console.error('Logout error:', err);
    } finally {
      authService.clearAuth();
      navigate('/login', { replace: true });
    }
  }, [navigate]);

  const getStatus = (user) => {
    if (!user.createdAt) {
      return 'Inactive';
    }

    const createdAt = new Date(user.createdAt);
    if (Number.isNaN(createdAt.getTime())) {
      return 'Inactive';
    }

    const diffDays = (Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24);
    return diffDays <= 30 ? 'Active' : 'Inactive';
  };

  const formatDate = (value) => {
    if (!value) return 'N/A';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return 'N/A';
    return new Intl.DateTimeFormat('en', {
      dateStyle: 'medium',
      timeStyle: 'short',
    }).format(date);
  };

  return (
    <div className="container page-section">
      <div className="page-heading">
        <div>
          <h2>Welcome back, {username}</h2>
          <p className="cta-note">Live user activity from the MySQL database.</p>
        </div>
        <button className="btn-secondary" onClick={handleLogout}>Logout</button>
      </div>

      <section className="stats-panel">
        <div className="stats-grid">
          <div className="stats-card">
            <h3>Total Registered Users</h3>
            <p className="stat-value">{stats.totalUsers}</p>
          </div>
          <div className="stats-card">
            <h3>Active Users</h3>
            <p className="stat-value">{stats.activeUsers}</p>
          </div>
          <div className="stats-card">
            <h3>New Users Today</h3>
            <p className="stat-value">{stats.newUsersToday}</p>
          </div>
        </div>
      </section>

      <section className="card-panel dashboard-panel">
        <div className="dashboard-toolbar">
          <div>
            <h3>Registered Users</h3>
            <p className="cta-note">Real data from MySQL, refreshed automatically.</p>
          </div>
          <input
            className="search-input"
            type="text"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search by name, username or email"
          />
        </div>

        {loading && <div className="loading-state">Loading users...</div>}
        {!loading && error && <div className="alert">{error}</div>}
        {!loading && !error && filteredUsers.length === 0 && (
          <div className="empty-state">No users found</div>
        )}

        {!loading && !error && filteredUsers.length > 0 && (
          <>
            <div className="table-wrapper">
              <table className="user-table">
                <thead>
                  <tr>
                    <th>Serial No.</th>
                    <th>Full Name</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Mobile Number</th>
                    <th>Registration Date</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedUsers.map((user, index) => (
                    <tr key={user.id || `${user.username}-${index}`}>
                      <td>{(page - 1) * PAGE_SIZE + index + 1}</td>
                      <td>{user.fullName || '—'}</td>
                      <td>{user.username || '—'}</td>
                      <td>{user.email || '—'}</td>
                      <td>{user.mobile || '—'}</td>
                      <td>{formatDate(user.createdAt)}</td>
                      <td><span className={`status-pill ${getStatus(user).toLowerCase()}`}>{getStatus(user)}</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {filteredUsers.length > PAGE_SIZE && (
              <div className="pagination">
                <button className="btn-ghost" onClick={() => setPage((prev) => Math.max(1, prev - 1))} disabled={page === 1}>
                  Previous
                </button>
                <span>Page {page} of {totalPages}</span>
                <button className="btn-ghost" onClick={() => setPage((prev) => Math.min(totalPages, prev + 1))} disabled={page === totalPages}>
                  Next
                </button>
              </div>
            )}
          </>
        )}
      </section>
    </div>
  );
}