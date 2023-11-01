resource "random_id" "security_policy_name" {
  byte_length = 16
}

locals {
  waf_policy_name = "wafpolicy1"
  security_policy_name = "${lower(random_id.security_policy_name.hex)}"
}

resource "azurerm_cdn_frontdoor_firewall_policy" "my_waf_policy" {
  name                              = local.waf_policy_name
  resource_group_name               = azurerm_resource_group.rg.name
  sku_name                          = azurerm_cdn_frontdoor_profile.my_front_door.sku_name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
 
  custom_rule {
    name                           = "FdWafCustRule"
    enabled                        = true
    priority                       = 100
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 100
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "SocketAddr"
      operator           = "IPMatch"
      negation_condition = true
      match_values       = [var.my_ip_address]
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "my_security_policy" {
  name                     = local.security_policy_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.my_waf_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}