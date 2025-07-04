# Kdd

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# Testing the Notion API locally

`Kdd.Notion.Account` 

Create a private integration in you Notion workspace and save its Internal Integration Secret in your local database in `notion_accounts.access_token`. 
You may use this as the `token` argument in the Notion library. 

Add a session to your browser by first creating a `user` record manually, with the above token associated, and then visiting `/dev/token`.
