{include file="../../sections/header.tpl"}

<div class="row">
    <div class="col-lg-12">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Add Hotspot Server</h5>
            </div>
            <div class="ibox-content">
                <form class="form-horizontal" method="post" role="form" action="{$_url}hotspot_server/add-post">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Router</label>
                        <div class="col-sm-10">
                            <select class="form-control" id="router" name="router">
                                {foreach $routers as $router}
                                    <option value="{$router->name}">{$router->name}</option>
                                {/foreach}
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Server Name</label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="server_name" name="server_name" placeholder="hotspot1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Interface</label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="interface" name="interface" placeholder="ether1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Pool Name</label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="pool_name" name="pool_name" placeholder="hotspot_pool">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Pool Ranges</label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="pool_ranges" name="pool_ranges" placeholder="192.168.89.2-192.168.89.254">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Hotspot Address</label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="hotspot_address" name="hotspot_address" placeholder="192.168.89.1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">DNS Name</label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="dns_name" name="dns_name" placeholder="login.hotspot.net">
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-sm-offset-2 col-sm-10">
                            <button type="submit" class="btn btn-primary">Add Server</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

{include file="../../sections/footer.tpl"}
