defmodule BinshopWeb.WebErrorViewTest do
  use BinshopWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 400.html" do
    assert render_to_string(BinshopWeb.Common.ErrorView, "400.html", []) ==
             "<div class=\"full-flex-col\">\n  <div class=\"grow col align-center justify-center\">\n    <div class=\"title\">Bad Request</div>\n    <div class=\"status\">400</div>\n    <div class=\"code\">400</div>\n    <div class=\"detail\">Server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing).</div>\n\n  </div>\n  <div class=\"\"></div>\n</div>\n"
  end

  test "renders 401.html" do
    assert render_to_string(BinshopWeb.Common.ErrorView, "401.html", []) ==
             "<div class=\"full-flex-col\">\n  <div class=\"grow col align-center justify-center\">\n    <div class=\"title\">Unauthorized</div>\n    <div class=\"status\">401</div>\n    <div class=\"code\">401</div>\n    <div class=\"detail\">Request has not been applied because it lacks valid authentication credentials for the target resource.</div>\n\n  </div>\n  <div class=\"\"></div>\n</div>\n"
  end

  test "renders 403.html" do
    assert render_to_string(BinshopWeb.Common.ErrorView, "403.html", []) ==
             "<div class=\"full-flex-col\">\n  <div class=\"grow col align-center justify-center\">\n    <div class=\"title\">Forbidden</div>\n    <div class=\"status\">403</div>\n    <div class=\"code\">403</div>\n    <div class=\"detail\">Server understood the request but refuses to authorize it.</div>\n\n  </div>\n  <div class=\"\"></div>\n</div>\n"
  end

  test "renders 404.html" do
    assert render_to_string(BinshopWeb.Common.ErrorView, "404.html", []) ==
             "<div class=\"full-flex-col\">\n  <div class=\"grow col align-center justify-center\">\n    <div class=\"title\">Not Found</div>\n    <div class=\"status\">404</div>\n    <div class=\"code\">404</div>\n    <div class=\"detail\">Server can&#39;t find the requested resource.</div>\n\n  </div>\n  <div class=\"\"></div>\n</div>\n"
  end

  test "renders 422.html" do
    assert render_to_string(BinshopWeb.Common.ErrorView, "422.html", []) ==
             "<div class=\"full-flex-col\">\n  <div class=\"grow col align-center justify-center\">\n    <div class=\"title\">Unprocessable Entity</div>\n    <div class=\"status\">422</div>\n    <div class=\"code\">422</div>\n    <div class=\"detail\">Unable to process the contained instructions.</div>\n\n  </div>\n  <div class=\"\"></div>\n</div>\n"
  end

  test "renders 500.html" do
    assert render_to_string(BinshopWeb.Common.ErrorView, "500.html", []) ==
             "<div class=\"full-flex-col\">\n  <div class=\"grow col align-center justify-center\">\n    <div class=\"title\">Internal Server Error</div>\n    <div class=\"status\">500</div>\n    <div class=\"code\">500</div>\n    <div class=\"detail\">Server encountered an unexpected condition that prevented it from fulfilling the request.</div>\n\n  </div>\n  <div class=\"\"></div>\n</div>\n"
  end

  test "renders 400.json" do
    assert %{
             "errors" => [
               %{
                 "code" => "400",
                 "detail" =>
                   "Server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing).",
                 "id" => _,
                 "source" => %{"parameter" => nil, "pointer" => nil},
                 "status" => "400",
                 "title" => "Bad Request"
               }
             ]
           } = render(BinshopWeb.Common.ErrorView, "400.json", [])
  end

  test "renders 401.json" do
    assert %{
             "errors" => [
               %{
                 "code" => "401",
                 "detail" =>
                   "Request has not been applied because it lacks valid authentication credentials for the target resource.",
                 "id" => _,
                 "source" => %{"parameter" => nil, "pointer" => nil},
                 "status" => "401",
                 "title" => "Unauthorized"
               }
             ]
           } = render(BinshopWeb.Common.ErrorView, "401.json", [])
  end

  test "renders 403.json" do
    assert %{
             "errors" => [
               %{
                 "code" => "403",
                 "detail" => "Server understood the request but refuses to authorize it.",
                 "id" => _,
                 "source" => %{"parameter" => nil, "pointer" => nil},
                 "status" => "403",
                 "title" => "Forbidden"
               }
             ]
           } = render(BinshopWeb.Common.ErrorView, "403.json", [])
  end

  test "renders 404.json" do
    assert %{
             "errors" => [
               %{
                 "code" => "404",
                 "detail" => "Server can't find the requested resource.",
                 "id" => _,
                 "source" => %{"parameter" => nil, "pointer" => nil},
                 "status" => "404",
                 "title" => "Not Found"
               }
             ]
           } = render(BinshopWeb.Common.ErrorView, "404.json", [])
  end

  test "renders 422.json" do
    assert %{
             "errors" => [
               %{
                 "code" => "422",
                 "detail" => "Unable to process the contained instructions.",
                 "id" => _,
                 "source" => %{"parameter" => nil, "pointer" => nil},
                 "status" => "422",
                 "title" => "Unprocessable Entity"
               }
             ]
           } = render(BinshopWeb.Common.ErrorView, "422.json", [])
  end

  test "renders 500.json" do
    assert %{
             "errors" => [
               %{
                 "code" => "500",
                 "detail" =>
                   "Server encountered an unexpected condition that prevented it from fulfilling the request.",
                 "id" => _,
                 "source" => %{"parameter" => nil, "pointer" => nil},
                 "status" => "500",
                 "title" => "Internal Server Error"
               }
             ]
           } = render(BinshopWeb.Common.ErrorView, "500.json", [])
  end
end
