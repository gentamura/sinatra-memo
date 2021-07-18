# Sinatra Memo

## Usage

1. Install gems.
```
bundle install
```

2. Install PostgreSQL if not exists.
[PostgreSQL Downloads](https://www.postgresql.org/download/)

3. Execute on local environments with PostgreSQL.

```
createdb memo_development
psql -d 'memo_development' -c 'CREATE TABLE memos(id varchar(10), title varchar(50), content text);'
```


4. Start a web app.
```
bundle exec ruby app.rb
```

5. Check it out.
