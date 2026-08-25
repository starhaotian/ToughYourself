# ToughYourself

> Make yourself tough — 让判断在时间里接受检验。

ToughYourself 是一款极简的个人决策记录与复盘工具。它不替你做决定，也不试图给出一个所谓的“最优答案”；它帮助你忠实地留下**做决定时掌握的信息、选择的理由和对结果的预期**，然后在约定的日期回来检验这次判断。

## 在线体验

访问：[https://tough-yourself.vercel.app](https://tough-yourself.vercel.app)

无需注册即可选择「不登录，仅本机使用」立即体验；也可以使用 Google 登录，在不同设备之间同步自己的决策记录。

## 为什么做 ToughYourself

我们经常只用最终结果评价一个决定：结果好，就觉得自己当初英明；结果坏，就认定当初选错了。但结果里总有运气，而记忆也会在事后悄悄改写当时的想法。

ToughYourself 想把“判断质量”和“最终运气”分开。做决定时，把几个关键问题写清楚：

- 我面前有哪些选择？
- 每个选择的好处和代价是什么？
- 我为什么最终选择这一条路？
- 到什么时间，用哪件具体的事情检验它？

到了约定日期，再根据真实发生的事情标记“对了、错了、还是一半”，并写下当时漏看了什么。长期积累后，你得到的不是一本流水账，而是一份关于自己如何判断、如何犯错、又如何变得更可靠的个人档案。

## 设计理念

### 记录当时，而不是解释后来

产品刻意保留“当时为什么选这条”和“后来发生了什么”两个视角。先保存原始判断，再补充后续信息，减少事后合理化和记忆偏差。

### 让判断可以被验证

每条决策都需要一个“回头看”的日期和一项具体的检验标准。模糊的期待很难复盘，只有预先写下可观察的信号，结论才有意义。

### 接受灰度，而不只判断输赢

现实很少只有全对或全错，因此结论提供“对了 / 错了 / 一半”三种选择。复盘的目的不是审判过去的自己，而是发现判断中哪些部分成立、哪些信息被忽略。

### 用时间组织，而不是用文件夹归档

日历既展示决定发生的时间，也提醒你何时回来验证。一次选择从“写下”走向“回头看”，形成自然、清晰的时间闭环。

### 数据属于用户

不登录时，数据只保存在当前浏览器；Google 登录后，数据同步到 Supabase，并通过行级安全策略按用户隔离。用户可以按自己对便利性和隐私的偏好选择使用方式。

## 核心功能

- 用日历查看决策的记录日与复盘日
- 记录多个选项，以及各自的理由、好处和代价
- 预先设定复盘日期和具体检验标准
- 补充后来发生的事实，并给出“对 / 错 / 一半”的结论
- 无账号的本机模式，以及 Google OAuth 云端同步模式
- 响应式单页设计，可在电脑和手机浏览器中使用

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
   - **Publishable key**（形如 `sb_publishable_...`）

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
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_...";
```

> Publishable key 本来就是给前端用的公开键，配合行级安全（`setup.sql` 已开启）是 Supabase 的标准做法。千万不要把 secret key 或旧版 `service_role` key 放进前端。

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
