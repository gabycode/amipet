const express = require("express");
const axios = require("axios");
const cors = require("cors");

require("dotenv").config();

const app = express();
app.use(cors());

const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;

let accessToken = null;
let tokenExpiresAt = 0;

async function getToken() {
  if (accessToken && Date.now() < tokenExpiresAt) {
    return accessToken;
  }

  try {
    const response = await axios.post(
      "https://api.petfinder.com/v2/oauth2/token",
      new URLSearchParams({
        grant_type: "client_credentials",
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
      })
    );

    accessToken = response.data.access_token;
    tokenExpiresAt = Date.now() + response.data.expires_in * 1000;

    return accessToken;
  } catch (error) {
    console.error(
      "Error getting token:",
      error.response?.data || error.message
    );
    throw error;
  }
}

app.get("/animals", async (req, res) => {
  try {
    const token = await getToken();

    const response = await axios.get("https://api.petfinder.com/v2/animals", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      params: req.query,
    });

    res.json(response.data);
  } catch (error) {
    console.error(
      "Error fetching animals:",
      error.response?.data || error.message
    );
    res.status(500).json({ error: "Error fetching animals" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
