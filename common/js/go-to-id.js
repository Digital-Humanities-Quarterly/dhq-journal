(() => {
  // Prefer an absolute path so it works no matter where the page sits.
  const INDEX_URL = "articles.json";

  function $(id) {
    return document.getElementById(id);
  }

  function setMsg(text) {
    const el = $("msg");
    if (el) el.textContent = text || "";
  }


function normalizeId(input) {
  if (!input) return "";

  // Trim whitespace
  let id = input.trim();

  // Remove any accidental non-digit characters
  id = id.replace(/\D+/g, "");

  if (!id) return "";

  // Pad to 6 digits
  return id.padStart(6, "0");
}

  async function loadIndex() {
    // Cache within the session so repeated lookups are fast.
    const cached = sessionStorage.getItem("goToIdIndex");
    if (cached) return JSON.parse(cached);

    const res = await fetch(INDEX_URL, { cache: "no-store" });
    if (!res.ok) throw new Error(`Failed to load ${INDEX_URL} (${res.status})`);
    const data = await res.json();
    sessionStorage.setItem("goToIdIndex", JSON.stringify(data));
    return data;
  }

  async function go(id) {
    id = normalizeId(id);
    if (!id) {
      setMsg("Enter an article ID.");
      return;
    }

    try {
      setMsg("Looking up…");
      const index = await loadIndex();
      const url = index[id];

      if (!url) {
        setMsg(`No entry found for ID ${id}.`);
        return;
      }

      // url is expected to be a site-root-relative path like "/vol/19/3/000802/000802.html"
      window.location.assign(url);
    } catch (e) {
      console.error(e);
      setMsg(`Error: ${e.message}`);
    }
  }

  function wireUp() {
    const input = $("articleId");
    const btn = $("goBtn");

    if (btn) btn.addEventListener("click", () => go(input ? input.value : ""));
    if (input) {
      input.addEventListener("keydown", (ev) => {
        if (ev.key === "Enter") go(input.value);
      });
    }

    // Support /go.html?id=000802
    const params = new URLSearchParams(window.location.search);
    const fromQuery = params.get("id");
    if (fromQuery) {
      if (input) input.value = fromQuery;
      go(fromQuery);
    } else {
      setMsg("");
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", wireUp);
  } else {
    wireUp();
  }
})();
