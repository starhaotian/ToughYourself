const BASE = "https://api.qoder.com/api/v1/cloud";

module.exports = async function handler(req, res) {
  const raw = req.query.path;
  const parts = Array.isArray(raw) ? raw : raw ? [raw] : [];
  if (!parts.length || parts.some((p) => !p || p.includes("..") || p.includes("/"))) {
    res.status(400).json({ error: "bad path" });
    return;
  }

  const url = new URL(BASE + "/" + parts.map(encodeURIComponent).join("/"));
  for (const [key, value] of Object.entries(req.query)) {
    if (key === "path") continue;
    const list = Array.isArray(value) ? value : [value];
    for (const item of list) {
      if (item != null && item !== "") url.searchParams.append(key, item);
    }
  }

  const auth = req.headers.authorization;
  if (!auth) {
    res.status(401).json({ error: "missing authorization" });
    return;
  }

  const headers = { Authorization: auth };
  if (req.headers["content-type"]) headers["Content-Type"] = req.headers["content-type"];

  const method = req.method || "GET";
  const init = { method, headers };
  if (method !== "GET" && method !== "HEAD" && method !== "OPTIONS") {
    if (typeof req.body === "string" && req.body) init.body = req.body;
    else if (req.body && typeof req.body === "object" && Object.keys(req.body).length) {
      init.body = JSON.stringify(req.body);
      if (!headers["Content-Type"]) headers["Content-Type"] = "application/json";
    }
  }

  let upstream;
  try {
    upstream = await fetch(url, init);
  } catch (err) {
    res.status(502).json({ error: "qoder unreachable" });
    return;
  }

  const buf = Buffer.from(await upstream.arrayBuffer());
  const ct = upstream.headers.get("content-type");
  if (ct) res.setHeader("Content-Type", ct);
  res.status(upstream.status).send(buf);
};
