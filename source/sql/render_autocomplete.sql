create or replace procedure render_autocomplete  (
    p_item in apex_plugin.t_page_item,
    p_plugin in apex_plugin.t_plugin,
    p_param in apex_plugin.t_item_render_param,
    p_result in out nocopy apex_plugin.t_item_render_result ) IS

    subtype plugin_attr is varchar2(32767);

    l_result apex_plugin.t_item_render_result;
    l_js_params varchar2(1000);
    l_onload_string_old varchar2(3000);
    l_onload_string varchar2(3000);

    -- Plugin attributes
    l_api_key plugin_attr := p_plugin.attribute_01;

    -- Component attributes
    l_action plugin_attr := p_item.attribute_01;
    l_address plugin_attr := p_item.attribute_02;
    l_city plugin_attr := p_item.attribute_03;
    l_state plugin_attr := p_item.attribute_04;
    l_zip plugin_attr := p_item.attribute_05;
    l_country plugin_attr := p_item.attribute_06;
    l_latitude plugin_attr := p_item.attribute_07;
    l_longitude plugin_attr := p_item.attribute_08;
    l_address_long plugin_attr := p_item.attribute_09;
    l_state_long plugin_attr := p_item.attribute_10;
    l_country_long plugin_attr := p_item.attribute_11;
    l_location_type plugin_attr := p_item.attribute_12;

begin

    -- Get API key for JS file name
    l_js_params := '?key=' || l_api_key || '&libraries=places';

    apex_javascript.add_library
          (p_name           => 'js' || l_js_params
          ,p_directory      => 'https://maps.googleapis.com/maps/api/'
          ,p_skip_extension => true);

    apex_javascript.add_library
      (p_name                  => 'jquery.ui.autoComplete'
      ,p_directory             => p_plugin.file_prefix);

    -- apex_javascript.add_library
    --   (p_name                  => 'autocomplete'
    --   ,p_directory             => p_plugin.file_prefix);

    -- For use with APEX 5.1 and up. Print input element.
    sys.htp.prn (apex_string.format('<input type="text" %s size="%s" maxlength="%s"/>'
                                    , apex_plugin_util.get_element_attributes(p_item, p_item.name, 'text_field')
                                    , p_item.element_width
                                    , p_item.element_max_length));
l_onload_string :=
'
$("#%NAME%").placesAutocomplete({
  pageItems : {
    autoComplete : {
      %AUTOCOMPLETE_ID%
    },
    lat : {
      %LAT_ID%
    },
    lng : {
      %LNG_ID%
    },
    route : {
      %ROUTE_ID%
    },
    locality : {
      %LOCALITY_ID%
    },
    administrative_area_level_1 : {
      %ADMINISTRATIVE_AREA_LEVEL_1_ID%
    },
    postal_code : {
      %POSTAL_CODE_ID%
    },
    country : {
      %COUNTRY_ID%
    }
  },
  address_components : {
    route : {
      %ROUTE_ID%
      %ROUTE_FORM%
    },
    locality : {
      %LOCALITY_ID%
      %LOCALITY_FORM%
    },
    administrative_area_level_1 : {
      %ADMINISTRATIVE_AREA_LEVEL_1_ID%
      %ADMINISTRATIVE_AREA_LEVEL_1_FORM%
    },
    postal_code : {
      %POSTAL_CODE_ID%
      %POSTAL_CODE_FORM%
    },
    country : {
      %COUNTRY_ID%
      %COUNTRY_FORM%
    }
  },
  %ACTION%
});
';
    l_onload_string := replace(l_onload_string,'%NAME%',p_item.name);
    l_onload_string := replace(l_onload_string, '%AUTOCOMPLETE_ID%', apex_javascript.add_attribute('id',  p_item.name));
    l_onload_string := replace(l_onload_string, '%ROUTE_ID%', apex_javascript.add_attribute('id',  l_address));
    l_onload_string := replace(l_onload_string, '%ROUTE_FORM%', apex_javascript.add_attribute('form',  CASE WHEN l_address_long = 'Y' THEN 'long_name' ELSE 'short_name' END));
    l_onload_string := replace(l_onload_string, '%LOCALITY_ID%', apex_javascript.add_attribute('id',  l_city));
    l_onload_string := replace(l_onload_string, '%LOCALITY_FORM%', apex_javascript.add_attribute('form',  'long_name'));
    l_onload_string := replace(l_onload_string, '%ADMINISTRATIVE_AREA_LEVEL_1_ID%', apex_javascript.add_attribute('id',  l_state));
    l_onload_string := replace(l_onload_string, '%ADMINISTRATIVE_AREA_LEVEL_1_FORM%', apex_javascript.add_attribute('form',  CASE WHEN l_state_long = 'Y' THEN 'long_name' ELSE 'short_name' END));
    l_onload_string := replace(l_onload_string, '%POSTAL_CODE_ID%', apex_javascript.add_attribute('id',  l_zip));
    l_onload_string := replace(l_onload_string, '%POSTAL_CODE_FORM%', apex_javascript.add_attribute('form',  'long_name'));
    l_onload_string := replace(l_onload_string, '%COUNTRY_ID%', apex_javascript.add_attribute('id',  l_country));
    l_onload_string := replace(l_onload_string, '%COUNTRY_FORM%', apex_javascript.add_attribute('form',  CASE WHEN l_country_long = 'Y' THEN 'long_name' ELSE 'short_name' END));
    l_onload_string := replace(l_onload_string, '%LAT_ID%', apex_javascript.add_attribute('id',  l_latitude));
    l_onload_string := replace(l_onload_string, '%LNG_ID%', apex_javascript.add_attribute('id',  l_longitude));
    l_onload_string := replace(l_onload_string, '%ACTION%', apex_javascript.add_attribute('action',  l_action));

    apex_javascript.add_inline_code(p_code => l_onload_string);
end render_autocomplete;