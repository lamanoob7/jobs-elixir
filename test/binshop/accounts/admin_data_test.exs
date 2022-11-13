defmodule Binshop.Accounts.AdminDataTest do
  use Binshop.DataCase, async: true

  alias Binshop.Accounts.AdminData

  describe "prepare_data/1 from google" do
    test "should return unified data for user" do
      test_data = %{
        credentials: %{
          expires: true,
          expires_at: 1_627_495_098,
          other: %{},
          refresh_token: nil,
          scopes: ["https://www.googleapis.com/auth/userinfo.email openid"],
          secret: nil,
          token:
            "ab29.a0ARrdaM_CgG-Fddg0tBp6_eSnWcZnXEuSLVMNJZTJSk5sp0Kxnv4U_lSuWBq9MFkiCjm_1sY7nU9JzEe-lk414TyJXH1OQGxXVyfm_WCqhnjM1AH0Y88BMC3XDvAZU897-RpPdXqKfrQqFJZeHEWL8f2Om3jmzg",
          token_type: "Bearer"
        },
        extra: %{
          raw_info: %{
            token: %{
              access_token:
                "ab29.a0ARrdaM_CgG-Fddg0tBp6_eSnWcZnXEuSLVMNJZTJSk5sp0Kxnv4U_lSuWBq9MFkiCjm_1sY7nU9JzEe-lk414TyJXH1OQGxXVyfm_WCqhnjM1AH0Y88BMC3XDvAZU897-RpPdXqKfrQqFJZeHEWL8f2Om3jmzg",
              expires_at: 1_627_495_098,
              other_params: %{
                "id_token" =>
                  "abJhbGciOiJSUzI1NiIsImtpZCI6IjNkZjBhODMxZTA5M2ZhZTFlMjRkNzdkNDc4MzQ0MDVmOTVkMTdiNTQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3ODc4Mjk1Nzc5NjUtczRlajY0a25sNG41M2ZidDRwNjJwaW1ncjM5NXZodnMuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3ODc4Mjk1Nzc5NjUtczRlajY0a25sNG41M2ZidDRwNjJwaW1ncjM5NXZodnMuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDYyNTY3MzQwODY1MDg4MjExODgiLCJoZCI6ImJpbmFyaW8uZGV2IiwiZW1haWwiOiJwZXRyLnNpbWVjZWtAYmluYXJpby5kZXYiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6IjJ6WGVCNGZ4aGxnRDFqeVJKeDY0LWciLCJpYXQiOjE2Mjc0OTE1MDEsImV4cCI6MTYyNzQ5NTEwMX0.UAL22K_kGf85QGuuzT711QzTXdrAGJQOGh90L_5TaWQcOWZQKcgNfkxPfZM7n9UuKaqQSpbApTLp40dBFpRJ-qd9tLYtIr60yUEJT556XqwhKuA5bqwxrRLE_Cuw5w4XENZWY97d_0ltyDy-LcUjLzTtxJfZF7O1reWJrGFjbsaDzjsdEl1WOsvgQA4ZhxReNywuD_rxh3PRarVP5FCQ4-czpKOAEi36GfH8Fo4mLrTgT-YD7fQGzlUSWdBtIIEE1sXgv_eexWmZXHceeTA4NAgM_h-GKby6hYTa6v6YWa33QDlZHtXo_6RjCwV6680c0WjAsSFL9OMiNVoPOjQZiQ",
                "scope" => "https://www.googleapis.com/auth/userinfo.email openid"
              },
              refresh_token: nil,
              token_type: "Bearer"
            },
            user: %{
              "email" => "admin_test_email@testgoogle.test",
              "email_verified" => true,
              "hd" => "binario.dev",
              "picture" => "http://admin_test_picture_url.testgoogle.test",
              "sub" => "test_sub"
            }
          }
        },
        info: %{
          birthday: nil,
          description: nil,
          email: "admin_test_email@testgoogle.test",
          first_name: "admin_test_google_first_name",
          image: "http://admin_test_picture_url.testgoogle.test",
          last_name: "admin_test_google_last_name",
          location: nil,
          name: nil,
          nickname: nil,
          phone: nil,
          urls: %{profile: nil, website: "binario.dev"}
        },
        provider: :google,
        strategy: Ueberauth.Strategy.Google,
        uid: "123456789012345678901"
      }

      assert %{
               email: email,
               picture: picture,
               subject_claim: :google,
               first_name: first_name,
               last_name: last_name,
               role: :admin
             } = AdminData.prepare_data(test_data)

      assert email == "admin_test_email@testgoogle.test"
      assert picture == "http://admin_test_picture_url.testgoogle.test"
      assert first_name == "admin_test_google_first_name"
      assert last_name == "admin_test_google_last_name"
    end
  end
end
