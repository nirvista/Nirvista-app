const { GoogleAuth } = require('google-auth-library');
const https = require('https');
const projectId = 'nirvista-63cce';
const keyFile = 'C:/Users/Rohan/Downloads/nirvista-63cce-firebase-adminsdk-fbsvc-66c9615360.json';

async function main() {
  const auth = new GoogleAuth({ keyFilename: keyFile, scopes: ['https://www.googleapis.com/auth/cloud-platform'] });
  const client = await auth.getClient();
  const tokenRes = await client.getAccessToken();
  const token = tokenRes.token;
  if (!token) {
    throw new Error('Failed to retrieve access token');
  }

  const endpoints = {
    web: `/v1beta/projects/${projectId}/webApps`,
    android: `/v1beta/projects/${projectId}/androidApps`,
    ios: `/v1beta/projects/${projectId}/iosApps`,
  };

  for (const [label, endpoint] of Object.entries(endpoints)) {
    const url = `https://firebase.googleapis.com${endpoint}`;
    console.log(`Fetching ${label} apps from ${url}`);
    const apps = await request(url, token);
    console.log(`${label} apps count: ${apps.length}`);
    if (apps.length > 0) {
      console.log(JSON.stringify(apps, null, 2));
    }
  }
}

function request(url, token) {
  return new Promise((resolve, reject) => {
    const options = new URL(url);
    options.headers = { Authorization: `Bearer ${token}` };
    https.get(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        if (res.statusCode && res.statusCode >= 400) {
          return reject(new Error(`Request failed ${res.statusCode}: ${data}`));
        }
        try {
          const json = JSON.parse(data);
          resolve(json.apps || []);
        } catch (err) {
          reject(err);
        }
      });
    }).on('error', reject);
  });
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
