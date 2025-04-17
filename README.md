# ❤️ RULITE — geoip.dat и geosite.dat для России

⚡ Автоматическая сборка **облегченных** файлов **`geoip.dat`** и **`geosite.dat`** каждые **40 минут** после выхода релиза [runetfreedom/russia-v2ray-rules-dat](https://github.com/runetfreedom/russia-v2ray-rules-dat), **только если файлы действительно изменились**.

🧠 Основано на:
- [@v2fly/domain-list-community](https://github.com/v2fly/domain-list-community)
- [Antifilter](https://antifilter.network/)
- [re:filter](https://github.com/1andrevich/Re-filter-lists)

🧪 В файлах оставлены только **актуальные категории**:
- **geosite.dat** ~3.5 MB
- **geoip.dat** ~1.5 MB
  
✅ Отлично подходит для пользователей **Happ на iOS**

---

## 📄 Ссылки

**GitHub:**
- [`geoip.dat`](https://github.com/sendmiche/rulite/releases/latest/download/geoip.dat)
- [`geosite.dat`](https://github.com/sendmiche/rulite/releases/latest/download/geosite.dat)

**CDN (jsDelivr):**
- [`geoip.dat`](https://cdn.jsdelivr.net/gh/sendmiche/rulite@latest/geoip.dat)
- [`geosite.dat`](https://cdn.jsdelivr.net/gh/sendmiche/rulite@latest/geosite.dat)

---

## ℹ️ Описание категорий

### 📁 GEOSITE

- `geosite:ru-blocked` — заблокированные в России домены (Antifilter + re:filter)  
- `geosite:ru-available-only-inside` — домены, доступные только внутри РФ  
- `geosite:category-ads-all` — все рекламные домены  
- `geosite:win-spy` — Windows-домены для аналитики и слежки  
- `geosite:win-update` — Windows-домены для обновлений  
- `geosite:win-extra` — прочие Windows-домены  

### 📁 GEOIP

- `geoip:ru-blocked` — IP из `ipresolve.lst` и `subnet.lst` (antifilter.download)  
- `geoip:ru-blocked-community` — IP из `community.lst` (community.antifilter.download)  
- `geoip:re-filter` — IP из `ipsum.lst` (re:filter)  

---

## 📋 Категории

| 🌍 geosite                   | 🌐 geoip                     |
|----------------------------|-----------------------------|
| geosite:adguard            | geoip:cloudflare            |
| geosite:adobe              | geoip:ddos-guard            |
| geosite:adobe-activation   | geoip:facebook              |
| geosite:adobe-ads          | geoip:google                |
| geosite:amazon             | geoip:kz                    |
| geosite:amazon-ads         | geoip:netflix               |
| geosite:android            | geoip:private               |
| geosite:apple              | geoip:ru                    |
| geosite:apple-ads          | geoip:ru-blocked            |
| geosite:apple-dev          | geoip:telegram              |
| geosite:apple-intelligence | geoip:twitter               |
| geosite:apple-pki          | geoip:yandex                |
| geosite:apple-tvplus       | geoip:re-filter             |
| geosite:apple-update       | geoip:ru-blocked-community  |
| geosite:azure              |                             |
| geosite:bing               |                             |
| geosite:category-ads-all   |                             |
| geosite:category-android-app-download |                 |
| geosite:category-anticensorship |                     |
| geosite:category-game-platforms-download |              |
| geosite:category-games     |                             |
| geosite:category-gov-ru    |                             |
| geosite:category-media-ru  |                             |
| geosite:category-public-tracker |                      |
| geosite:category-ru        |                             |
| geosite:category-speedtest |                             |
| geosite:cloudflare         |                             |
| geosite:discord            |                             |
| geosite:ebay               |                             |
| geosite:epicgames          |                             |
| geosite:facebook           |                             |
| geosite:facebook-ads       |                             |
| geosite:facebook-dev       |                             |
| geosite:gitbook            |                             |
| geosite:github             |                             |
| geosite:gitlab             |                             |
| geosite:google             |                             |
| geosite:google-ads         |                             |
| geosite:google-deepmind    |                             |
| geosite:google-gemini      |                             |
| geosite:google-play        |                             |
| geosite:google-registry    |                             |
| geosite:google-registry-tld|                             |
| geosite:google-scholar     |                             |
| geosite:google-trust-services |                         |
| geosite:googlefcm          |                             |
| geosite:icloud             |                             |
| geosite:icloudprivaterelay |                             |
| geosite:imdb               |                             |
| geosite:instagram          |                             |
| geosite:instagram-ads      |                             |
| geosite:intel              |                             |
| geosite:intel-dev          |                             |
| geosite:itunes             |                             |
| geosite:linkedin           |                             |
| geosite:mailru             |                             |
| geosite:mdn                |                             |
| geosite:meta               |                             |
| geosite:meta-ads           |                             |
| geosite:microsoft          |                             |
| geosite:microsoft-dev      |                             |
| geosite:microsoft-pki      |                             |
| geosite:msn                |                             |
| geosite:netflix            |                             |
| geosite:nintendo           |                             |
| geosite:ok                 |                             |
| geosite:ookla-speedtest    |                             |
| geosite:ookla-speedtest-ads|                             |
| geosite:onedrive           |                             |
| geosite:openai             |                             |
| geosite:origin             |                             |
| geosite:playstation        |                             |
| geosite:private            |                             |
| geosite:reddit             |                             |
| geosite:rockstar           |                             |
| geosite:ru-available-only-inside |                     |
| geosite:ru-blocked         |                             |
| geosite:rutracker          |                             |
| geosite:signal             |                             |
| geosite:speedtest          |                             |
| geosite:spotify            |                             |
| geosite:spotify-ads        |                             |
| geosite:steam              |                             |
| geosite:telegram           |                             |
| geosite:tiktok             |                             |
| geosite:tmdb               |                             |
| geosite:trackernetwork     |                             |
| geosite:tumblr             |                             |
| geosite:twitch             |                             |
| geosite:twitter            |                             |
| geosite:vk                 |                             |
| geosite:whatsapp           |                             |
| geosite:whatsapp-ads       |                             |
| geosite:win-extra          |                             |
| geosite:win-spy            |                             |
| geosite:win-update         |                             |
| geosite:xbox               |                             |
| geosite:yandex             |                             |
| geosite:youtube            |                             |
| geosite:zoom               |                             |

---

✍️ Сделано с ❤️
