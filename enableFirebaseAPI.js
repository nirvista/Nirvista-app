const { GoogleAuth } = require('google-auth-library');
const https = require('https');
const projectId = 'nirvista-63cce';
const keyFile = 'C:/Users/Rohan/Downloads/nirvista-63cce-firebase-adminsdk-fbsvc-66c9615360.json';

async function main() {
  const auth = new GoogleAuth({ keyFilename: keyFile, scopes: ['https://www.googleapis.com/auth/cloud-platform'] });
  const client = await auth.getClient();
  const tokenRes = await client.getAccessToken();
  const token = tokenRes.token;
  if (!token) throw new Error('Failed to get token');

  const url = `https://serviceusage.googleapis.com/v1/projects/${projectId}/services/firebase.googleapis.com:enable`;
  const result = await request(url, token, 'POST', JSON.stringify({}));
  console.log('Enable response:', result);
}

function request(url, token, method = 'GET', body = null) {
  return new Promise((resolve, reject) => {
    const options = new URL(url);
    options.method = method;
    options.headers = { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode && res.statusCode >= 400) {
          return reject(new Error(`Request failed ${res.statusCode}: ${data}`));
        }
        resolve(data ? JSON.parse(data) : {});
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

main().catch(err => { console.error(err); process.exit(1); });
