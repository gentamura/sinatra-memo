# Sinatra Memo

## Usage

1. Install gems.
```
bundle install
```

2. Execute on local environments with PostgreSQL.

```
createdb memo_development
psql -d 'memo_development' -c 'CREATE TABLE memos(id varchar(10), title varchar(50), content text);'
```


3. Start a web app.
```
bundle exec ruby app.rb
```

4. Check it out.
