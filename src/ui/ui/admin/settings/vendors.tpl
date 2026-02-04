{include file="admin/layout/header.tpl"}

<div class="row">
    <div class="col-lg-12">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Router Vendors</h5>
            </div>
            <div class="ibox-content">
                <table class="table table-striped b-t b-light" data-page-size="10" data-filter="#filter">
                    <thead>
                    <tr>
                        <th>Name</th>
                        <th>Status</th>
                        <th>Manage</th>
                    </tr>
                    </thead>
                    <tbody>
                    {foreach $vendors as $vendor}
                        <tr>
                            <td>{$vendor->name}</td>
                            <td>
                                {if $vendor->enabled}
                                    <span class="label label-primary">Enabled</span>
                                {else}
                                    <span class="label label-danger">Disabled</span>
                                {/if}
                            </td>
                            <td>
                                <a href="{$_url}settings/vendors-toggle/{$vendor->id}" class="btn btn-{$vendor->enabled ? 'danger' : 'primary'} btn-xs">
                                    {$vendor->enabled ? 'Disable' : 'Enable'}
                                </a>
                            </td>
                        </tr>
                    {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

{include file="admin/layout/footer.tpl"}
