# ToughYourself

make yourself tough

用日历记下会被打分的选择，到期回头看对了、错了、还是一半。

## 使用方式

- 打开网页即用。「不登录，仅本机使用」时，数据只存在当前浏览器，不经过服务器。
- 用 Google 登录后，数据自动同步云端，换设备、换浏览器不丢。
  - Google 登录需要能访问 Google（国内用户建议选「仅本机使用」）。

## 部署上线（Vercel + Supabase + Google 登录，全程免费）

整体结构：`index.html` 托管在 Vercel；Google 登录与数据存放在你自己的 Supabase 项目，无需写任何后端代码。

### 第 1 步：创建 Supabase 项目

1. 用 GitHub 账号登录 [supabase.com](https://supabase.com)，New Project 新建项目
2. 打开 SQL Editor，把本仓库 [`setup.sql`](./setup.sql) 的内容粘贴执行（建表并开启行级安全，每人只能读写自己的数据）
3. 记下 Project Settings → API 里的两样东西：
   - **Project URL**（形如 `https://abcd1234.supabase.co`）
   - **anon public key**

### 第 2 步：配置 Google 登录

在 [Google Cloud Console](https://console.cloud.google.com)：

1. 新建项目 → 「API 和服务」→「OAuth 同意屏幕」：User Type 选 External，填应用名、邮箱；完成后点「发布应用」（保持 Testing 状态时只有测试账号能登录）
2. 「凭据」→「创建凭据」→「OAuth 客户端 ID」→ 应用类型 Web application：
   - 已获授权的 JavaScript 来源：`https://abcd1234.supabase.co`（你的 Supabase 域名）、部署后的线上域名、`http://localhost:8080`
   - 已获授权的重定向 URI：`https://abcd1234.supabase.co/auth/v1/callback`
3. 保存后得到 **Client ID** 和 **Client Secret**

在 Supabase：

1. Authentication → Providers → Google：开启，粘贴 Client ID / Client Secret
2. Authentication → URL Configuration：
   - Site URL：线上域名（第 4 步部署完拿到后回来填）
   - Redirect URLs：加上线上域名和 `http://localhost:8080`（如需所有 Vercel 预览地址可用通配 `https://*.vercel.app`）

### 第 3 步：填写项目配置

编辑 [`index.html`](./index.html) 顶部的「部署配置」区，换成你自己的值：

```js
const SUPABASE_URL = "https://abcd1234.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOi...（你的 anon key）";
```

> anon key 本来就是给前端用的公开键，配合行级安全（`setup.sql` 已开启）是 Supabase 的标准做法。千万不要把 service_role key 放进前端。

### 第 4 步：部署到 Vercel

1. 把本仓库推到你自己的 GitHub 仓库
2. [vercel.com](https://vercel.com) → Add New… → Project → 导入该仓库 → Framework Preset 选 **Other**（无需构建）→ Deploy
3. 拿到 `xxx.vercel.app` 域名后，回到第 2 步把它补进 Google 的 JavaScript 来源和 Supabase 的 Site URL / Redirect URLs

之后每次 `git push`，Vercel 会自动部署最新版本。

## 本地运行

- 直接双击 `index.html`：可完整使用「仅本机」模式
- 本地调试 Google 登录：`python3 -m http.server 8080`，打开 `http://localhost:8080`

## 数据说明

- 仅本机模式：数据存浏览器 localStorage，清浏览器数据会丢失
- 登录模式：数据存你的 Supabase 项目，每个账号一行，行级安全保证互相隔离；本机会留一份缓存，断网时仍可查看；首次登录时会把本机已有的记录自动带上云端
- Supabase 免费项目若连续 7 天无人访问会自动休眠，进控制台点一下即可恢复
