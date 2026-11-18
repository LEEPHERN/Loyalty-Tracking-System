# TaxDraft MY local proxy — forwards /v1/chat/completions to api.ilmu.ai,
# adding CORS headers so the browser app can call it. Requires .NET (Windows default).
# Run: powershell -ExecutionPolicy Bypass -File .\proxy.ps1   (listens on port 8765)
$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
$cs = @"
using System;
using System.IO;
using System.Net;
using System.Text;
public class ProxyServer {
    public static void Run(string appRoot) {
        var listener = new HttpListener();
        listener.Prefixes.Add("http://localhost:8765/");
        listener.Start();
        Console.WriteLine("TaxDraft MY running on http://localhost:8765/ - press Ctrl+C to stop.");
        while (true) {
            var ctx = listener.GetContext();
            try {
                var res = ctx.Response;
                res.Headers.Add("Access-Control-Allow-Origin", "*");
                res.Headers.Add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
                res.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization");
                if (ctx.Request.HttpMethod == "OPTIONS") { res.StatusCode = 204; res.Close(); continue; }
                if (ctx.Request.Url.AbsolutePath == "/" || ctx.Request.Url.AbsolutePath == "/index.html") {
                    var html = File.ReadAllBytes(Path.Combine(appRoot, "index.html"));
                    res.StatusCode = 200; res.ContentType = "text/html; charset=utf-8";
                    res.ContentLength64 = html.Length;
                    res.OutputStream.Write(html, 0, html.Length); res.Close(); continue;
                }
                if (!ctx.Request.Url.AbsolutePath.StartsWith("/v1/")) {
                    res.StatusCode = 404; res.Close(); continue;
                }
                string body;
                using (var r = new StreamReader(ctx.Request.InputStream)) body = r.ReadToEnd();
                var upstream = WebRequest.CreateHttp("https://api.ilmu.ai" + ctx.Request.Url.PathAndQuery);
                upstream.Method = "POST";
                upstream.ContentType = "application/json";
                var auth = ctx.Request.Headers["Authorization"];
                if (auth != null) upstream.Headers.Add("Authorization", auth);
                var bytes = Encoding.UTF8.GetBytes(body);
                upstream.ContentLength = bytes.Length;
                using (var s = upstream.GetRequestStream()) s.Write(bytes, 0, bytes.Length);
                try {
                    using (var up = (HttpWebResponse)upstream.GetResponse())
                    using (var rs = up.GetResponseStream()) {
                        var data = new MemoryStream(); rs.CopyTo(data);
                        res.StatusCode = (int)up.StatusCode;
                        res.ContentType = up.ContentType;
                        var outb = data.ToArray();
                        res.ContentLength64 = outb.Length;
                        res.OutputStream.Write(outb, 0, outb.Length);
                    }
                } catch (WebException wex) {
                    using (var up = (HttpWebResponse)wex.Response)
                    using (var rs = up.GetResponseStream()) {
                        var data = new MemoryStream(); rs.CopyTo(data);
                        res.StatusCode = (int)up.StatusCode;
                        res.ContentType = up.ContentType;
                        var outb = data.ToArray();
                        res.ContentLength64 = outb.Length;
                        res.OutputStream.Write(outb, 0, outb.Length);
                    }
                }
                res.Close();
            } catch (Exception ex) {
                Console.WriteLine("Error: " + ex.Message);
                try { ctx.Response.StatusCode = 500; ctx.Response.Close(); } catch {}
            }
        }
    }
}
"@
Add-Type -TypeDefinition $cs
[ProxyServer]::Run($scriptRoot)
