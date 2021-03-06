## The contents of this file are subject to the Common Public Attribution
## License Version 1.0. (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License at
## http://code.reddit.com/LICENSE. The License is based on the Mozilla Public
## License Version 1.1, but Sections 14 and 15 have been added to cover use of
## software over a computer network and provide for limited attribution for the
## Original Developer. In addition, Exhibit A has been modified to be
## consistent with Exhibit B.
##
## Software distributed under the License is distributed on an "AS IS" basis,
## WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
## the specific language governing rights and limitations under the License.
##
## The Original Code is reddit.
##
## The Original Developer is the Initial Developer.  The Initial Developer of
## the Original Code is reddit Inc.
##
## All portions of the code written by reddit are Copyright (c) 2006-2015
## reddit Inc. All Rights Reserved.
###############################################################################

<%!
  from r2.lib.media import thumbnail_url
  from r2.lib.filters import jssafe, scriptsafe_dumps
  from r2.lib.pages import UserText
  import simplejson
  from babel.numbers import format_currency
%>

<%namespace file="utils.m" 
            import="error_field, checkbox, image_upload" />
<%namespace name="utils" file="utils.m"/>

<%def name="javascript_setup()">
<script type="text/javascript">
  r.sponsored.init();
  r.sponsored.set_form_render_fnc(r.sponsored.fill_campaign_editor);
  r.sponsored.setup(${unsafe(simplejson.dumps(thing.inventory))},
                    ${unsafe(simplejson.dumps(thing.price_dict))},
                    ${simplejson.dumps(not thing.campaigns)},
                    ${simplejson.dumps(c.user_is_sponsor)},
                    ${simplejson.dumps(thing.force_auction)});
  r.sponsored.setup_geotargeting(${unsafe(simplejson.dumps(thing.regions))},
                                 ${unsafe(simplejson.dumps(thing.metros))});
  r.sponsored.setup_collections(${unsafe(simplejson.dumps(thing.collections))});
</script>
</%def>

## Create a datepicker for a form. min/maxDateSrc are the id of the
## element containing the min/max date - the '#' is added automatically
## here (as a workaround for babel message extraction not handling it
## properly if passed in when the function is called
<%def name="datepicker(name, value, minDateSrc = '', maxDateSrc ='', initfuncname = '', min_date_offset=0)">
  <div class="date-input">
    <input name="${name}"
           value="${value}" id="${name}" class="rounded styled-input" readonly="readonly" size="10" />
    <div id="datepicker-${name}" class="datepicker"></div>
    ${error_field("BAD_DATE", name, "div")}
    ${error_field("START_DATE_CANNOT_CHANGE", name, "div")}
    ${error_field("DATE_TOO_EARLY", name, "div")}
    ${error_field("DATE_TOO_LATE", name, "div")}
    <script type="text/javascript">
      ${initfuncname} = function() {
          attach_calendar("#${name}", "#${minDateSrc}", "#${maxDateSrc}",
                          ${caller.body()}, ${min_date_offset})
      };
    </script>
  </div>
</%def>

<%def name="title_field(link)">
  <%utils:line_field title="${_('title')}" id="title-field" css_class="rounded title-field">
    <textarea name="title" rows="2" cols="1" 
              wrap="hard" class="rounded">${link.title if link else ''}</textarea>
    ${error_field("NO_TEXT", "title", "div")}
    ${error_field("TOO_LONG", "title", "div")}
    <div class="help infotext rounded">
      <p>${_("A good title is important to the success of your campaign. reddit users are an intelligent, thoughtful group, and reward those who engage them.")}</p>
    </div>
  </%utils:line_field>
</%def>

<%def name="content_field(link, enable_override=False, tracker_access=False)">
  <%
    is_link = not link or not link.is_self
    text = link.selftext if link else ''
    url = link and link.url
  %>
  <%utils:line_field title="${_('post type')}" id="kind-selector" css_class="rounded post-type-field">
    <div class="radio-group">
      <label class="form-group">
        <input id="url_link" class="nomargin" 
               type="radio" value="link" name="kind"
               onclick="$('#text-field').hide(); $('#url-field').show()"
               ${"checked='checked'" if is_link else ""}>
        <div class="label-group">
          <span class="label">${_("link")}</span>
          <small class="label">${_("clicks through to your URL")}</small>
        </div>
      </label>
      <label class="form-group">
        <input id="self_link" class="nomargin" 
               type="radio" value="self" name="kind"
               onclick="$('#url-field').hide(); $('#text-field').show()"
               ${"" if is_link else "checked='checked'"}>
        <div class="label-group">
          <span class="label">${_("text")}</span>
          <small class="label">${_("clicks through to text you customize")}</small>  
        </div>
      </label>
    </div>
  </%utils:line_field>
  <%utils:line_field title="${_('text')}" id="text-field" css_class="rounded text-field"
                     style="${('' if not is_link else 'display:none')}">
    ${UserText(None, text=text, textarea_class='rounded', have_form=False,
               creating=True)}
  </%utils:line_field>
  <%utils:line_field title="${_('url')}" id="url-field" css_class="rounded url-field"
                     style="${('' if is_link else 'display:none')}">
    <input id="url" name="url" type="text" 
           value="${(url if is_link else '') if link else ""}"
           class="rounded">
    ${error_field("NO_URL", "url", "div")}
    ${error_field("BAD_URL", "url", "div")}
    ${error_field("DOMAIN_BANNED", "url", "div")}
    ${error_field("TOO_LONG", "url", "div")}
    <div class="help infotext rounded">
      <p>${_("Provide the URL of your ad. No redirects please!")}</p>
    </div>

    %if enable_override:
      <label style="display:block; text-align:right" for="domain">${_("Override display domain:")}</label>
      <input id="domain" name="domain" type="text"
             %if link and link.domain_override:
               value="${link.domain_override}" class="rounded"
             %else:
               class="rounded" placeholder="optional"
             %endif
      >
      <div class="infotext rounded">
        <p>${_("Choose a different domain name to display on the site (the small grey text next to a link)")}</p>
      </div>

      <label style="display:block; text-align:right" for="third_party_tracking">${_("Impression tracking URL:")}</label>
      <input id="third_party_tracking" name="third_party_tracking" type="text"
             %if link and link.third_party_tracking:
               value="${link.third_party_tracking}" class="rounded"
             %else:
               class="rounded" placeholder="optional"
             %endif
      >
      <div class="infotext rounded">
        <p>${_("Enter a URL to insert into a 3rd-party impression tracking code snippet")}</p>
      </div>

      <label style="display:block; text-align:right" for="third_party_tracking_2">${_("Secondary Impression tracking URL:")}</label>
      <input id="third_party_tracking_2" name="third_party_tracking_2" type="text"
             %if link and link.third_party_tracking_2:
               value="${link.third_party_tracking_2}" class="rounded"
             %else:
               class="rounded" placeholder="optional (not common)"
             %endif
      >
      <div class="infotext rounded">
        <p>${_("Enter a second 3rd-party impression tracking URL (not common)")}</p>
      </div>
    %endif
  </%utils:line_field>
</%def>

<%def name="image_field(link=None, images=None)">
  <% 
    if link:
      thumbnail_url = getattr(link, "thumbnail_url", None)
      mobile_url = getattr(link, "mobile_ad_url", None)
      path = "ads/%s" % link._id36
    else:
      thumbnail_url = images.get("thumbnail", None)
      mobile_url = images.get("mobile", None)
      path = "ads/%s" % c.user.name
  %>
  <%utils:line_field
      title="${_('thumbnail')}" 
      css_class="rounded image-field">
    <div class="infotext">
      ${_('images will be resized if larger than 140x140 pixels (displayed at 70x70)')}
    </div>
    ${utils.s3_image_upload(
      id="thumbnail",
      width="70",
      height="70",
      src=thumbnail_url,
      data=dict(
        max=(1024**2) * 3,
        url="/api/ad_s3_params.json",
        params=simplejson.dumps(dict(
          kind="thumbnail",
          link=(link and link._id36),
        )),
      ),
    )}
  </%utils:line_field>

  %if thing.mobile_targeting_enabled:
    <%utils:line_field title="${_('mobile ad image')}"
                       css_class="rounded image-field">
      <div class="infotext">
        ${_('upload image for use on mobile web.  should be exactly 1200x628 pixels (displayed at 600x314)')}
      </div>
      ${utils.s3_image_upload(
        id="mobile",
        width="600",
        height="314",
        src=mobile_url,
        data=dict(
          max=(1024**2) * 3,
          url="/api/ad_s3_params.json",
          params=simplejson.dumps(dict(
            kind="mobile",
            link=(link and link._id36),
          )),
        ),
      )}
    </%utils:line_field>
  %endif
</%def>

<%def name="commenting_field(link)">
  <%utils:line_field title="${_('options')}" id="commenting-field" css_class="rounded commenting-field">
    <div class="checkbox-group">
      <div class="form-group">
        ${checkbox("disable_comments", _("disable comments"), link.disable_comments)}
      </div>
      
      <div class="form-group">
        ${checkbox("sendreplies", _("send comments on my ad to my inbox"), link.sendreplies)}
      </div>
    </div>

    <div class="help infotext">
      <p>${_("Comments are a great way to get feedback from customers, and the reddit community is known for being vocal in comment threads.")}</p>
    </div>
  </%utils:line_field>
</%def>

<%def name="media_field(link)">
  <%utils:line_field title="${_('media')}" id="media-field" css_class="rounded media-field">
    <div class="delete-field">
      <div class="radio-group">
        <%
          scraper_checked = link.media_url or not link.gifts_embed_url
        %>
        <label class="form-group checkbox">
          <input type="radio" id="scrape" value="scrape" name="media_url_type"
                 ${"checked='checked'" if scraper_checked else ''}>
          <span class="label">scraper</span>
        </label>
        <label class="form-group checkbox">
          <input type="radio" id="redditgifts" value="redditgifts" name="media_url_type"
                 ${"checked='checked'" if not scraper_checked else ''}>
          <span class="label">redditgifts</span>
        </label>
      </div>
      <p id="scraper_input" ${"" if scraper_checked else "style='display:none'"}>
        <label for="media_url">source URL to scrape</label>
        <input id="media_url" name="media_url" type="text" class="rounded"
               value="${link.media_url or ""}"
               ${"" if scraper_checked else "disabled"}>
        ${error_field("BAD_URL", "media_url", "div")}
        ${error_field("SCRAPER_ERROR", "media_url", "div")}
      </p>
      <p id="rg_input" ${"style='display:none'" if scraper_checked else ""}>
        <label for="gifts_embed_url">redditgifts embed URL</label>
        <input id="gifts_embed_url" name="gifts_embed_url" type="text" class="rounded"
               value="${link.gifts_embed_url or ''}"
               ${"disabled" if scraper_checked else ""}>
        ${error_field("BAD_URL", "gifts_embed_url", "div")}
      </p>
      ${checkbox("media_autoplay",
                 _("autoplay"),
                 link.media_autoplay)}
      <br>
      ${checkbox("media-override",
                 _("media override (adds an onclick to the link to generate a drop-down rather than a link out)"),
                 getattr(link, "media_override", False) or False)}
      <br>
    </div>
  </%utils:line_field>
</%def>

<%def name="managed_field(link)">
  <%utils:line_field title="" id="managed-field" css_class="rounded managed-field">
    <div class="checkbox-group">
      <div class="form-group">
        ${checkbox("is_managed", _("managed promotion"), link.managed_promo if link else False)}
      </div>
      <div class="infotext rounded">
        <p>${_("Managed promotions don't appear in the selfserve approval queues.")}</p>
      </div>
    </div>
  </%utils:line_field>
</%def>

<%def name="scheduling_field()">
  <%utils:line_field title="${_('scheduling')}" css_class="rounded timing-field">
    %if thing.min_start:
      <input type="hidden" id="date-min" value="${thing.min_start}">
    %endif
    %if thing.max_start:
      <input type="hidden" id="date-start-max" value="${thing.max_start}">
    %endif
    %if thing.max_end:
      <input type="hidden" id="date-end-max" value="${thing.max_end}">
    %endif

    <div class="group">
      <div class="form-group">
        <span class="label">${_("start")}</span>
        <div class="input-group">
          <%self:datepicker name="startdate", value="${thing.default_start}"
                            minDateSrc="date-min" maxDateSrc="date-start-max"
                            initfuncname="init_startdate">
            function(elem) {
              check_enddate(elem, $("#enddate"));
              r.sponsored.on_date_change();
            }
          </%self:datepicker>
        </div>
      </div>
      <div class="form-group">
        <span class="label">${_("end")}</span>
        <div class="input-group">
        <%self:datepicker name="enddate", value="${thing.default_end}"
                            minDateSrc="startdate" maxDateSrc="date-end-max"
                            initfuncname="init_enddate" min_date_offset="86400000">
            function(elem) { r.sponsored.on_date_change(); }
          </%self:datepicker>
        </div>
      </div>
      <div class="form-group">
        <span class="label">${_("duration")}</span>
        <div class="display-text duration"></div>
      </div>
    </div>
    <div>
      ${error_field("BAD_DATE_RANGE", "enddate", "div")}
    </div>
  </%utils:line_field>
</%def>

<%def name="platform_field()">
  <input type="hidden" id="mobile_os" name="mobile_os" value="">
  <%def name="platform_field_content(default_checked='desktop')">
    <div class="radio-group platform-group">
      <span class="label">platform</span>
      <label class="form-group">
        <input id="all_platform" class="nomargin"
               type="radio" value="all" name="platform"
               %if default_checked == 'all':
                 checked="checked"
               %endif
               >
        <div class="label-group">
          <span class="label">${_("desktop and mobile web")}</span>
        </div>
      </label>
      <label class="form-group">
        <input id="desktop_platform" class="nomargin"
               type="radio" value="desktop" name="platform"
               %if default_checked == 'desktop':
                 checked="checked"
               %endif
               >
        <div class="label-group">
          <span class="label">${_("desktop only")}</span>
        </div>
      </label>
      <label class="form-group">
        <input id="mobile_platform" class="nomargin"
               type="radio" value="mobile" name="platform"
               %if default_checked == 'mobile':
                 checked="checked"
               %endif
               >
        <div class="label-group">
          <span class="label">${_("mobile web only")}</span>
        </div>
      </label>
    </div>
    <div class="checkbox-group mobile-os-group">
      <span class="label">mobile OS</span>
      <label class="form-group">
        <input type="checkbox" checked id="mobile_os_iOS" value="iOS">
        <span class="label">${_("iOS")}</span>
      </label>
      <label class="form-group">
        <input type="checkbox" checked id="mobile_os_Android" value="Android">
        <span class="label">${_("Android")}</span>
      </label>
      ${error_field("BAD_PROMO_MOBILE_OS", "mobile_os", "div")}
      <div class="error">
        ${_("you must select at least one mobile OS")}
      </div>
    </div>
    <div class="os-device-group">
      <div class="radio-group">
        <span class="label">device and OS version</span>
        <label class="form-group">
          <input id="all_os_devices" class="nomargin"
                 type="radio" value="all" name="os_versions"
                 checked="checked"
                 >
          <div class="label-group">
            <span class="label">${_("All")}</span>
          </div>
        </label>
        <label class="form-group">
          <input id="filter_os_devices" class="nomargin"
                 type="radio" value="filter" name="os_versions"
                 >
          <div class="label-group">
            <span class="label">${_("Filter by device and OS")}</span>
          </div>
        </label>
      </div>
      <div class="device-version-group ios-group">
        <input type="hidden" id="ios_device" name="ios_device" value="">
        <div class="checkbox-group ios-device">
          <label class="form-group">
            <input type="checkbox" id="iphone" value="iPhone" checked>
            <span class="label">${_("iPhone")}</span>
          </label>
          <label class="form-group">
            <input type="checkbox" id="ipad" value="iPad" checked>
            <span class="label">${_("iPad")}</span>
          </label>
          <label class="form-group">
            <input type="checkbox" id="ipod" value="iPod" checked>
            <span class="label">${_("iPod")}</span>
          </label>
        </div>
        <input type="hidden" id="ios_version_range"
               name="ios_version_range">
        <div class="select-group version-select ios-min-version">
          <label class="form-group">
            <span class="label">${_("Min")}</span>
            <select id="ios_min" title="${_('iOS min')}"
              %for version in thing.ios_versions:
              <option ${"selected='selected'" if selected else ""} value="${version}">
                ${version}
              </option>
              %endfor
            </select>
          </label>
        </div
        <div class="select-group version-select ios-max-version">
          <label class="form-group">
            <span class="label">${_("Max")}</span>
            <select id="ios_max" title="${_('iOS max')}">
              <option ${"selected='selected'" if selected else ""} value="">
                no max
              </option>
              %for version in thing.ios_versions:
              <option ${"selected='selected'" if selected else ""} value="${version}">
                ${version}
              </option>
              %endfor
            </select>
          </label>
        </div>
      </div>
      <div class="device-version-group android-group">
        <input type="hidden" id="android_device" name="android_device">
        <div class="checkbox-group android-device">
          <label class="form-group">
            <input type="checkbox" id="phone" value="phone" checked>
            <span class="label">${_("Android Phone")}</span>
          </label>
          <label class="form-group">
            <input type="checkbox" id="tablet" value="tablet" checked>
            <span class="label">${_("Android Tablet")}</span>
          </label>
        </div>
        <input type="hidden" id="android_version_range"
               name="android_version_range">
        <div class="select-group version-select android-min-version">
          <label class="form-group">
            <span class="label">${_("Min")}</span>
            <select id="android_min" title="${_('android min')}"
              %for version in thing.android_versions:
              <option ${"selected='selected'" if selected else ""} value="${version}">
                ${version}
              </option>
              %endfor
            </select>
          </label>
        </div
        <div class="select-group version-select android-max-version">
          <label class="form-group">
            <span class="label">${_("Max")}</span>
            <select id="android_max" title="${_('Android max')}">
              <option ${"selected='selected'" if selected else ""} value="">
                no max
              </option>
              %for version in thing.android_versions:
              <option ${"selected='selected'" if selected else ""} value="${version}">
                ${version}
              </option>
              %endfor
            </select>
          </label>
        </div>
      </div>
      ${error_field("BAD_PROMO_MOBILE_DEVICE", "os_versions", "div")}
      ${error_field("INVALID_OS_VERSION", "os_version", "div")}
      <div class="error version-error">
        ${_("you must select valid versions to target")}
      </div>
      <div class="error device-error">
        ${_("you must select at least one device per OS to target")}
      </div>
    </div>
  </%def>

  %if thing.mobile_targeting_enabled:
    <%utils:line_field title="${_('platform')}" css_class="rounded platform-field">
      ${platform_field_content()}
    </%utils:line_field>
  %else:
    <div class="platform-field" style="display:none">
      ${platform_field_content()}
    </div>
  %endif
</%def>

<%def name="frequency_cap_field(default_checked='false')">
  <%def name="frequency_select_content()">
    <div class="radio-group group">
      <span class="label">frequency capping</span>
      <label class="form-group">
        <input id="frequency_capped_false" class="nomargin"
               type="radio" value="false" name="frequency_capped"
               onclick="r.sponsored.toggleFrequency()"
               %if default_checked == 'false':
                 checked="checked"
               %endif
               >
        <div class="label-group">
          <span class="label">${_("no frequency cap")}</span>
        </div>
      </label>
      <label class="form-group">
        <input id="frequency_capped_true" class="nomargin"
               type="radio" value="true" name="frequency_capped"
               onclick="r.sponsored.toggleFrequency()"
               %if default_checked == 'true':
                 checked="checked"
               %endif
               >
        <div class="label-group">
          <span class="label">${_("frequency capped")}</span>
        </div>
      </label>

    </div>
  </%def>

  <%def name="frequency_details_content()">
    <div class="group frequency-cap-inputs">
      <div>
        <div class="form-group">
          <span class="label">${_("cap per 24 hours")}</span>
          <div class="input-group">
            <input id="frequency_cap" name="frequency_cap" size="7" type="text"
                   class="rounded style-input"
                   style="width:auto"
                   onkeyup="r.sponsored.on_frequency_cap_change()"
                   data-frequency_cap_min="${thing.frequency_cap_min}"/>
          </div>
        </div>
      </div>
    </div>
    <div class="frequency-cap-message example">
      ${_('Example: Display this flight no more than %i times per user per 24 hours.' %
          g.frequency_cap_min)}
    </div>
    <div class="frequency-cap-message error">
      ${_("frequency must be at least %i per 24 hours" % thing.frequency_cap_min)}
    </div>
    ${error_field("INVALID_FREQUENCY_CAP", "frequency_cap", "div")}
    ${error_field("FREQUENCY_CAP_TOO_LOW", "frequency_cap", "div")}
  </%def>

  %if c.user_is_sponsor:
    <%utils:line_field title="${_('frequency')}" css_class="rounded">
      ${frequency_select_content()}
      <div class="frequency-cap-field hidden">
        ${frequency_details_content()}
      </div>
    </%utils:line_field>
  %endif
</%def>

<%def name="priority_field()">
  <%def name="priority_field_content()">
    <div class="radio-group">
      %for value, text, description, default, override, house in thing.priorities:
        %if value != 'auction':
          <label class="form-group checkbox">
            <input id="${value}" class="nomargin" 
                   type="radio"  value="${value}" name="priority"
                   onclick="r.sponsored.priority_changed()"
                   ${"checked='checked'" if default else ""}
                   data-default="${simplejson.dumps(default)}"
                   data-override="${simplejson.dumps(override)}"
                   data-house="${simplejson.dumps(house)}">
            %if description:
              <span class="label">${"%s (%s)" % (text, description)}</span>
            %else:
              <span class="label">${text}</span>
            %endif
          %endif
        </label>
      %endfor
    </div>
  </%def>

  %if c.user_is_sponsor:
    <%utils:line_field title="${_('priority')}" css_class="rounded priority-field hidden">
      ${priority_field_content()}
    </%utils:line_field>
  %endif
</%def>

<%def name="pricing_field()">
  <%utils:line_field title="${_('pricing')}" css_class="rounded pricing-field auction-field">
    <div class="pricing-message"></div>
    <div class="group"> 
      %if thing.cpc_pricing:
        <div class="form-group pricing-group">
          <span class="label">Cost basis</span>
          <div class="cost-basis-select">
            <select class="cost-basis-select" id="cost_basis" name="cost_basis"
                    title="${_("price basis")}"
                    onchange="r.sponsored.on_cost_basis_change()">
              <option ${"selected='selected'" if selected else ""} value="cpc">
                CPC
              </option>
              <option value="cpm">
                CPM
              </option>
            </select>
            ${error_field("INVALID_LOCATION", "location", "div")}
          </div>
        </div>
      %else:
        <input type="hidden" id="cost_basis" name="cost_basis" value="cpm"/>
      %endif
      <div class="form-group">
        <span class="label cost-basis-label" id="cost-basis-label"></span>
        <div class="input-group">
          $<input id="bid_dollars" name="bid_dollars" size="7"
                  type="text" class="rounded styled-input"
                  style="width:auto"
                  onchange="r.sponsored.on_bid_change()"
                  onkeyup="r.sponsored.on_bid_change()"
                  value="${'%.2f' % (g.default_bid_pennies / 100.)}"
                  data-default_bid_dollars="${g.default_bid_pennies / 100.}"
                  data-min_bid_dollars="${thing.min_bid_dollars}"
                  data-max_bid_dollars="${thing.max_bid_dollars}"/>
        </div>
        ${error_field('BAD_BID', 'bid', 'div')}
      </div>
      <div class="form-group">
        
      </div>
    </div>
  </%utils:line_field>
</%def>

<%def name="budget_field()">
  <%utils:line_field title="${_('budget')}" css_class="rounded budget-field">
    <div class="group">
      <div class="form-group">
        <span class="label">${_("total budget")}</span>
        <div class="input-group">
          $<input id="total_budget_dollars" name="total_budget_dollars" size="7" type="text"
                  class="rounded styled-input"
                  style="width:auto"
                  onchange="r.sponsored.on_budget_change()"
                  onkeyup="r.sponsored.on_budget_change()"
                  value="${'%.2f' % thing.default_budget_dollars}"
                  data-default_budget_dollars="${thing.default_budget_dollars}"
                  data-min_budget_dollars="${thing.min_budget_dollars}"
                  data-max_budget_dollars="${thing.max_budget_dollars}"/>
          <div class="minimum-spend">
            ${_('%(minimum)s minimum') % dict(minimum=format_currency(thing.min_budget_dollars, 'USD', locale=c.locale))}
          </div>
        </div>
      </div>
      <div class="form-group fixed-cpm-field">
        <span class="label">${_("impressions")}</span>
        <input id="impressions" name="impressions" size="10" type="text"
               class="rounded styled-input"
               onchange="r.sponsored.on_impression_change()">
      </div>
      <div class="form-group fixed-cpm-field">
        <span class="label">${_("price")}</span>
        <div class="display-text price-info"></div>
      </div>
    </div>

    <div>
      <div class="budget-message auction-field">
        Your daily spend will not exceed <span class="display-text daily-max-spend"></span>.
      </div>
    </div>

    <div>
      ${error_field("BAD_BUDGET", "total_budget_dollars", "div")}
      ${error_field("BUDGET_LIVE", "total_budget_dollars", "div")}
      <div class="budget-change-warning error">
        ${_('if you modify the budget of this paid campaign you will need to reauthorize payment by clicking the "pay" button')}
      </div>
      <div class="budget-unchangeable-warning error">
        ${_('the budget for campaigns cannot be adjusted once the campaign has gone live')}
      </div>
      <div class="available-info"></div>
      ${error_field("OVERSOLD_DETAIL", "total_budget_dollars", "div")}
    </div>
  </%utils:line_field>
</%def>

<%def name="targeting_field(default_checked='collection')">
  <%utils:line_field title="${_('targeting')}" css_class="rounded targeting-field">
    <div class="radio-group group">
      <span class="label">target</span>
      <label class="form-group">
        <input id="collection_targeting" class="nomargin"
               type="radio" value="collection" name="targeting"
               onclick="r.sponsored.collection_targeting()"
               %if default_checked == 'collection':
                 checked="checked"
               %endif
               >
        <div class="label-group">

          <span class="label">${_("interests")}</span>
          <small class="label">${_("targets a collection of similar subreddits")}</small>
        </div>
      </label>
      <label class="form-group">
        <input id="subreddit_targeting" class="nomargin"
               type="radio" value="one" name="targeting"
               onclick="r.sponsored.subreddit_targeting()"
               %if default_checked == 'one':
                 checked="checked"
               %endif
               >
        <div class="label-group">
          <span class="label">${_("subreddits")}</span>
          <small class="label">${_("targets a subreddit and its subscribers")}</small>
        </div>
      </label>
    </div>
    <div class="target-group group">
      <div class="collection-targeting"
           %if default_checked != 'collection':
             style="display:none"
           %endif
           >
        <span class="label">${_("interest audience group")}</span>
        <div class="collection-selector uninitialized">
          <div class="widget-container">
            <div class="form-group-list">
            </div>
          </div>
        </div>
        <div class="collection-subreddit-list">
          <div class="label frontpage-label">
            ${_("subreddits included on the frontpage are based on users\' subscriptions")}
          </div>
          <div class="label collection-label" style="display:none;">
            ${_('includes these %s' % g.brander_community_plural)}
            &#32;<a href="/wiki/advertising/interestaudiencegroups">${_('and more!')}</a>
          </div>
          <ul></ul>
          ${error_field("COLLECTION_NOEXIST", "collection", "div")}
        </div>
      </div>
      <div class="subreddit-targeting"
           %if default_checked != 'one':
             style="display:none"
           %endif
           >
        <span class="label">subreddit</span>
        ${error_field("OVERSOLD", "sr", "div")}
        ${thing.subreddit_selector}
      </div>
      <div class="target-change-warning error">
        ${_('changing the target for a live campaign requires reapproval.')}
        ${_('while your campaign is awaiting reapproval, it will not be displayed.')}
      </div>
    </div>
    <div class="select-group geotargeting-group">
      <span class="label">location</span>
      <div class="geotargeting-disabled" style="display:none">
        ${_("location targeting is only available when targeting the frontpage")}
      </div>
      <div class="geotargeting-selects">
        <select class="geotarget-select" id="country" name="country"
                title="${_("country")}"
                onchange="r.sponsored.country_changed()">
          %for code, name, selected in thing.countries:
          <option ${"selected='selected'" if selected else ""} value="${code}">
            ${name}
          </option>
          %endfor
        </select>
        <select class="geotarget-select" id="region" name="region"
                title="${_("region")}" style="display:none"
                onchange="r.sponsored.region_changed()"></select>
        <select class="geotarget-select" id="metro" name="metro"
                title="${_("metro")}" style="display:none"
                onchange="r.sponsored.metro_changed()"></select>
        ${error_field("INVALID_LOCATION", "location", "div")}
      </div>
    </div>
  </%utils:line_field>
</%def>

<%def name="subreddit_targeting_field(subreddit_selector)">
  <%utils:line_field title="${_('subreddit targeting')}" css_class="rounded subreddit-targeting-field">
    <div class="target-group group">
      <div class="subreddit-targeting">
        <span class="label">subreddit</span>
        ${error_field("OVERSOLD", "sr", "div")}
        ${subreddit_selector}
      </div>
    </div>
  </%utils:line_field>
</%def>

<%def name="reporting_field(link_text='', owner='')">
  <%utils:line_field title="${_('report')}" css_class="rounded reporting-field">
    <label class="form-group">
      <div class="label">${_('link ids')}</div>
      <textarea name="link_text">${link_text}</textarea>
      ${error_field("BAD_LINKS", "bad_links", "div")}
    </label>
    <label class="form-group">
      <div class="label">${_('owner')}</div>
      <input type="text" name="owner" value="${owner}" />
    </label>
  </%utils:line_field>
</%def>

<%def name="admin_panel()">
  %if c.user_is_sponsor:
    <div class="spacer bidding-history">
      %if thing.bids:
        <%utils:line_field title="${_('spend history')}" css_class="rounded">
          <table class="bid-table">
            <tr>
              <th>date</th>
              <th>user</th>
              <th>transaction id</th>
              <th>campaign id</th>
              <th>pay id</th>
              <th>spend</th>
              <th>charge</th>
              <th>status</th>
            </tr>
            %for bid in thing.bids:
              <tr class="bid-${bid.status}">
                <td>${bid.date}</td>
                <td>${bid.bidder}</td>
                <td>${bid.transaction}</td>
                <td>${bid.campaign}</td>
                <td>${bid.pay_id}</td>
                <td>${bid.amount_str}</td>
                <td>${bid.charge_str}</td>
                <td class="bid-status">${bid.status}</td>
              </tr>
            %endfor
          </table>
        </%utils:line_field>
      %endif

      <form id="promotion-history" method="post" action="/post/promote_note"
            onsubmit="post_form(this, 'promote_note'); $('#promote_note').val('');return false;">
        <%utils:line_field title="${_('promotion history')}" css_class="rounded">
          <div style="font-size:smaller; margin-bottom: 10px;">
            For correspondence, the email address of this author is&#32;
            <a href="mailto:${thing.author.email}">${thing.author.email}</a>.
          </div>

          <div style="font-size:smaller; margin-bottom: 10px;">
            To check with&#32;<a href="https://account.authorize.net/">authorize.net</a>,
            use CustomerID&#32;<b>${thing.author._fullname}</b>&#32; when searching by batch.
          </div>

          <input type="hidden" name="link" value="${thing.link._fullname}"/>
          <label for="promote_note">add note:</label>
          <input id="promote_note" name="note" value="" type="text" size="40" />
          <button type="submit">save</button>
          <div class="notes">
            %for line in thing.promotion_log:
              <p>${line}</p>
            %endfor
          </div>
        </%utils:line_field>
      </form>
    </div>
  %endif
</%def>

<%def name="is_auction_field()">
  <%def name="is_auction_field_content()">
    <div class="radio-group">
      <label class="form-group">
        <input id="is_auction_true" class="nomargin"
               type="radio" value="true" name="is_auction"
               onclick="r.sponsored.toggleAuctionFields()"
               >
        <div class="label-group">
          <span class="label">${_('auction')}</span>
        </div>
      </label>
      <label class="form-group">
        <input id="is_auction_false" class="nomargin"
               type="radio" value="false" name="is_auction"
               onclick="r.sponsored.toggleAuctionFields()"
               >
        <div class="label-group">
          <span class="label">${_('fixed CPM')}</span>
        </div>
      </label>
    </div>
  </%def>
  %if thing.auction_optional:
    <%utils:line_field title="${_('campaign type')}" css_class="rounded">
      ${is_auction_field_content()}
    </%utils:line_field>
  %endif
</%def>

<%def name="is_new_field()">
  <input type="hidden" id="is_new" name="is_new" value="true">
</%def>
