# My Boke 开发文档

> 适用项目：my_boke 个人博客  
> 文档版本：2026-08-07  
> 技术栈：Ruby 3.3.x、Rails 8.1、MySQL、Puma、Hotwire、Action Text、Active Storage

## 1. 项目简介

My Boke 是一个基于 Ruby on Rails 的个人博客系统，已经实现：

- 文章创建、查看、编辑和删除；
- 纯文字、纯图片及图文混合文章；
- Trix 富文本编辑和图片拖拽上传；
- 文章搜索、分页与首页文章总数；
- 评论发布、删除、数量展示与分页；
- 以 /api 为前缀的文章和评论 JSON API；
- API 分页、评论数量和统一错误响应；
- 通过配置文件控制的 CORS 跨域访问；
- 北京时间展示和 Ngrok 临时公网访问。

## 2. 系统架构

项目采用 Rails MVC 架构：

~~~text
浏览器或 API 客户端
        ↓ HTTP 请求
config/routes.rb
        ↓ 路由匹配
Controller
        ↓ 参数过滤、分页、业务调用
Model / Active Record
        ↓
MySQL + Action Text + Active Storage
        ↓
HTML 页面、JSON 或重定向响应
~~~

网页请求由 ArticlesController 和 CommentsController 处理；API 请求由 Api 命名空间下的控制器处理。两类控制器共用 Article、Comment 模型及验证规则。

## 3. 主要目录

~~~text
app/
├── controllers/
│   ├── articles_controller.rb
│   ├── comments_controller.rb
│   └── api/
│       ├── base_controller.rb
│       ├── articles_controller.rb
│       └── comments_controller.rb
├── models/
├── views/articles/
└── assets/stylesheets/application.css
config/
├── application.rb
├── blog.yml
├── database.yml
├── routes.rb
└── initializers/cors.rb
db/
├── migrate/
└── schema.rb
storage/                 # 开发环境上传文件
test/
├── controllers/
└── integration/
~~~

## 4. 环境要求

| 组件 | 当前版本或要求 |
|---|---|
| Ruby | .ruby-version 指定 3.3.8 |
| Rails | 8.1.3.1 |
| 数据库 | MySQL，utf8mb4 |
| Web 服务器 | Puma |
| 文件存储 | Active Storage 本地磁盘 |

### 4.1 Windows 与 WSL

Windows Ruby 和 WSL Ruby 是两个独立环境，Gem 不能共用。在 PowerShell 安装过 Gem，不代表 WSL 已安装。

WSL 首次安装：

~~~bash
sudo apt update
sudo apt install -y build-essential default-libmysqlclient-dev
cd /mnt/d/code_ruby/my_boke
bundle install
~~~

Windows PowerShell：

~~~powershell
cd D:\code_ruby\my_boke
bundle install
~~~

不要执行 sudo bundle install，否则 Gem 可能进入 root 用户目录。

## 5. 本地初始化

### 5.1 安装依赖

~~~bash
bundle install
bundle info rails
bundle info mysql2
bundle info rack-cors
~~~

### 5.2 配置数据库

数据库配置位于 config/database.yml：

- 开发库：my_boke_development；
- 测试库：my_boke_test；
- DB_HOST 可覆盖默认数据库主机；
- WSL 连接 Windows MySQL 时，主机通常不是 WSL 的 localhost。

初始化：

~~~bash
bundle exec rails db:create
bundle exec rails db:migrate
~~~

当前开发账号密码仍写在 database.yml 中，正式提交前应改成环境变量：

~~~yaml
username: <%= ENV.fetch("DB_USERNAME") %>
password: <%= ENV.fetch("DB_PASSWORD") %>
host: <%= ENV.fetch("DB_HOST", "127.0.0.1") %>
~~~

### 5.3 启动

~~~bash
bundle exec rails server
~~~

默认地址：http://127.0.0.1:3000。使用 Ctrl+C 停止。

## 6. 数据模型

### 6.1 Article

主要关联：

~~~ruby
has_many :comments, dependent: :destroy
has_one_attached :cover_image
has_rich_text :rich_content
~~~

- 删除文章时同步删除所属评论；
- cover_image 保存独立封面；
- rich_content 由 Action Text 保存正文和正文内嵌图片；
- 标题必填；
- 正文文字、内嵌图片、封面图至少存在一项。

因此纯文字、纯图片、图文混合都可以保存，完全空内容不能保存。

### 6.2 Comment

~~~ruby
belongs_to :article
validates :commenter, presence: true
validates :body, presence: true
~~~

评论必须属于文章，昵称和内容不能为空。

### 6.3 数据表

| 表 | 作用 |
|---|---|
| articles | 文章标题、旧正文列和时间 |
| comments | 评论内容、昵称和文章外键 |
| action_text_rich_texts | Trix 富文本 |
| active_storage_blobs | 文件元数据 |
| active_storage_attachments | 文件关联 |
| active_storage_variant_records | 图片变体记录 |

文件二进制默认位于 storage。迁移或备份时必须同时保存 MySQL 数据与 storage。

## 7. 配置文件

业务配置位于 config/blog.yml，通过以下代码加载：

~~~ruby
config.x.blog = config_for(:blog)
~~~

| 配置项 | 默认值 | 作用 |
|---|---:|---|
| web_per_page | 5 | 首页每页文章数 |
| comments_per_page | 5 | 详情页每页评论数 |
| api_per_page | 5 | API 默认每页数 |
| api_max_per_page | 50 | API 每页上限 |
| cors.allowed_origins | 来源列表 | 允许读取 API 的网页来源 |

修改 blog.yml、Gem、路由或初始化器后应重启 Rails。

## 8. 网页端路由

| 方法 | 路径 | 作用 |
|---|---|---|
| GET | / | 首页 |
| GET | /articles | 列表、搜索和分页 |
| GET | /articles/new | 新建表单 |
| POST | /articles | 发布文章 |
| GET | /articles/:id | 文章详情 |
| GET | /articles/:id/edit | 编辑表单 |
| PATCH/PUT | /articles/:id | 更新文章 |
| DELETE | /articles/:id | 删除文章 |
| POST | /articles/:article_id/comments | 发表评论 |
| DELETE | /articles/:article_id/comments/:id | 删除评论 |

首页查询示例：

~~~text
/articles?query=Rails&page=2
~~~

- query 是搜索关键词；
- page 是文章页码；
- 首页显示当前搜索条件对应的文章总数；
- 分页链接保留 query。

评论分页：

~~~text
/articles/11?comments_page=2#comments
~~~

comments_page 独立于首页 page；评论按时间倒序；锚点让页面回到评论区。

## 9. JSON API

API 使用 /api 前缀，只返回 JSON。

### 9.1 文章 API

| 方法 | 路径 | 作用 |
|---|---|---|
| GET | /api/articles | 列表、搜索、分页和评论数 |
| GET | /api/articles/:id | 查看文章 |
| POST | /api/articles | 创建文章 |
| PATCH/PUT | /api/articles/:id | 更新文章 |
| DELETE | /api/articles/:id | 删除文章 |

列表请求：

~~~text
GET /api/articles?page=1&per_page=5&query=Rails
~~~

响应结构：

~~~json
{
  "articles": [
    {
      "id": 11,
      "title": "示例文章",
      "content": "<div>正文</div>",
      "cover_image_url": null,
      "comments_count": 3,
      "created_at": "2026-08-07T09:00:00.000+08:00",
      "updated_at": "2026-08-07T09:00:00.000+08:00"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 5,
    "total_count": 12,
    "total_pages": 3
  }
}
~~~

创建纯文字文章：

~~~bash
curl -X POST http://127.0.0.1:3000/api/articles \
  -H "Content-Type: application/json" \
  -d '{"article":{"title":"API 文章","rich_content":"正文内容"}}'
~~~

### 9.2 评论 API

| 方法 | 路径 | 作用 |
|---|---|---|
| GET | /api/articles/:article_id/comments | 评论列表和分页 |
| GET | /api/articles/:article_id/comments/:id | 查看评论 |
| POST | /api/articles/:article_id/comments | 创建评论 |
| PATCH/PUT | /api/articles/:article_id/comments/:id | 更新评论 |
| DELETE | /api/articles/:article_id/comments/:id | 删除评论 |

创建评论：

~~~bash
curl -X POST http://127.0.0.1:3000/api/articles/11/comments \
  -H "Content-Type: application/json" \
  -d '{"comment":{"commenter":"访客","body":"API 评论"}}'
~~~

### 9.3 分页规则

- page 无效、缺失或小于 1 时使用第 1 页；
- per_page 无效或缺失时读取 api_per_page；
- per_page 超过 api_max_per_page 时限制为 50；
- pagination 返回 current_page、per_page、total_count、total_pages。

### 9.4 状态码

| 状态码 | 含义 |
|---:|---|
| 200 | 查询或更新成功 |
| 201 | 创建成功 |
| 204 | 删除成功，无正文 |
| 404 | 资源不存在 |
| 422 | 模型验证失败 |

~~~json
{ "error": "资源不存在" }
~~~

~~~json
{ "errors": ["具体校验错误"] }
~~~

## 10. CORS 跨域

rack-cors 只为 /api/* 添加跨域规则。允许来源读取 config/blog.yml：

~~~yaml
cors:
  allowed_origins:
    - http://localhost:3000
    - http://127.0.0.1:3000
~~~

若前端运行在 5173，应增加：

~~~yaml
- http://localhost:5173
- http://127.0.0.1:5173
~~~

允许 GET、POST、PUT、PATCH、DELETE、OPTIONS、HEAD。

预检测试：

~~~bash
curl -i -X OPTIONS \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  http://127.0.0.1:3000/api/articles
~~~

合法来源应收到 Access-Control-Allow-Origin。生产环境不要随意允许 *，应填写明确的前端域名。

## 11. 时间与语言

~~~ruby
config.time_zone = "Beijing"
config.active_record.default_timezone = :utc
config.i18n.default_locale = :"zh-CN"
~~~

数据库按 UTC 保存，Rails 读取后转换为北京时间；已有数据不需要修改即可自动按北京时间显示。

## 12. 图片上传

- 开发环境使用 Active Storage local；
- 文件位于 storage；
- 封面由 cover_image 管理；
- 正文图片由 rich_content.embeds 管理；
- API 的 cover_image_url 是签名 URL；
- 列表预加载附件和富文本，减少 N+1 查询。

不要把 storage 当作缓存清理。生产环境建议使用 S3、OSS 等对象存储。

## 13. 测试与检查

~~~bash
bundle exec rails test
bundle exec rails test test/controllers
bundle exec rails test test/integration/api_cors_test.rb
bundle exec rails routes -g api
bundle exec rails zeitwerk:check
bundle exec rubocop
bundle exec brakeman
bundle exec bundler-audit check --update
~~~

如果 Windows Ruby 连接 MySQL 时出现：

~~~text
TLS/SSL error: no credentials
SEC_E_NO_CREDENTIALS
~~~

这是 MySQL/Windows Schannel 环境问题，不等于控制器逻辑或断言失败。应先修复测试数据库连接。

## 14. Ngrok 公网访问

Rails 启动后，在另一个终端执行：

~~~powershell
cd D:\tool\ngrok
.\ngrok.exe http 3000
~~~

身份令牌一般只需首次配置：

~~~powershell
.\ngrok.exe config add-authtoken "你的完整令牌"
~~~

Ngrok 域名需要加入 development.rb 的 Rails Host Authorization。域名变化后应同步修改并重启。不要提交身份令牌。

## 15. 常用命令

| 命令 | 作用 |
|---|---|
| bundle install | 安装 Gem |
| bundle exec rails server | 启动服务 |
| bundle exec rails console | Rails 控制台 |
| bundle exec rails routes | 查看路由 |
| bundle exec rails db:create | 创建数据库 |
| bundle exec rails db:migrate | 执行迁移 |
| bundle exec rails db:rollback | 回滚迁移 |
| bundle exec rails db:schema:dump | 更新 schema |
| bundle exec rails test | 运行测试 |

查看日志：

~~~bash
tail -f log/development.log
~~~

~~~powershell
Get-Content log\development.log -Wait
~~~

## 16. 已知问题与后续建议

### 高优先级

1. 增加管理员认证，保护文章写操作和评论删除操作。
2. 将数据库密码迁移到环境变量或 Rails Credentials，并更换已经暴露的密码。
3. 为公网 API 增加认证、限流和操作日志。

### 中优先级

1. 新正文存于 Action Text 表，但当前搜索仍查询 articles.content，新文章正文关键词可能搜不到。
2. 数据量增大后可使用 Pagy 或 Kaminari，并增加必要索引。
3. 生产图片迁移到对象存储。
4. API 序列化逻辑可拆到 Serializer。

### 低优先级

1. 确认无旧数据依赖后清理 articles.content。
2. 把固定 Ngrok Host 改为环境变量。
3. 为 API 增加版本前缀，例如 /api/v1。

## 17. 开发约定

- 数据结构变化必须创建 migration，不直接编辑 schema.rb；
- 新增控制器行为时同步增加测试；
- API 保持一致的顶层资源名和错误格式；
- 可变业务参数放入 blog.yml 或环境变量；
- 不提交数据库密码、Ngrok Token 和生产密钥；
- 修改 Gem、初始化器、路由或 blog.yml 后重启 Rails；
- 合并代码前执行相关测试、路由和 Zeitwerk 检查。

## 18. 新开发者检查清单

- [ ] Ruby 版本与项目一致；
- [ ] 已在当前 Windows 或 WSL 环境执行 bundle install；
- [ ] MySQL 服务已启动，开发库和测试库可以连接；
- [ ] 已执行 rails db:migrate；
- [ ] 纯文字、纯图片、图文混合可以提交；
- [ ] 文章分页、文章总数和评论分页正常；
- [ ] 文章与评论 API 正常返回 JSON；
- [ ] API 分页和最大值限制生效；
- [ ] 合法来源具有 CORS 响应头；
- [ ] 自动化测试和安全检查已执行；
- [ ] 公网使用前已配置认证和敏感信息保护。

