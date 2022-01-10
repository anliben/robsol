import { HttpClient } from '@angular/common/http';
import { Component, OnInit, ViewChild } from '@angular/core';
import { PoBreadcrumb, PoDynamicViewField, PoModalComponent, PoMultiselectOption, PoSelectOption } from '@po-ui/ng-components';
import { PoPageDynamicTableActions, PoPageDynamicTableCustomAction, PoPageDynamicTableCustomTableAction, PoPageDynamicTableOptions } from '@po-ui/ng-templates';
import { ProdutosService } from './produtos.service';

@Component({
  selector: 'app-produtos',
  templateUrl: './produtos.component.html',
  styleUrls: ['./produtos.component.scss']
})
export class ProdutosComponent implements OnInit {
  @ViewChild('userDetailModal')
  userDetailModal!: PoModalComponent;

  serviceApi = `http://200.98.81.201:40160/rest/Products?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  detailedUser!: { codigo: any; descricao: any; ean: any; grupo: any; imagem: any; ncm: any; saldo: any; tipo: any; um: any; };
  quickSearchWidth: number = 3;

  readonly actions: PoPageDynamicTableActions = {
    new: '/',
  };

  readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Produtos' }]
  };
  readonly fields: Array<any> = []


  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [
    {
      label: 'Details',
      action: this.onClickUserDetail.bind(this),
      icon: 'po-icon po-icon-pushcart'
    }
  ];

  readonly detailFields: Array<PoDynamicViewField> = [];


  constructor(public http: HttpClient) {}

  ngOnInit(): void {
    if(localStorage.getItem('tipo') == 'cliente'){
      this.serviceApi = `http://200.98.81.201:40160/rest/Products?CLIENTE=${localStorage.getItem('cod_cliente')}`;
    }
  }


  onLoad(): PoPageDynamicTableOptions {
    return {
      fields: [
        { property: 'codigo', allowColumnsManager: true, label: 'Codigo', gridLgColumns: 4 , filter: true},
        { property: 'descricao', allowColumnsManager: true, label: 'Descricão', gridLgColumns: 8 , filter: true},
        { property: 'cor', label: "Cor", gridLgColumns: 4, filter: true},
        { property: 'marca', label: 'Marca', gridLgColumns: 6, allowColumnsManager: true, filter: true},
        { property: 'linha', gridLgColumns: 4, filter: true},
        { property: 'material', gridLgColumns: 4, filter: true },
        { property: 'genero', gridLgColumns: 4, filter: true },
      ]
    };
  }


  private onClickUserDetail(user: { [x: string]: any; }) {
    console.log(user)
    let produtosapi = this.serviceApi + `&codigo=${user['codigo']}`
    this.http.get(produtosapi).subscribe((res: any)=>{
      this.detailedUser = res
    })
    this.userDetailModal.open();
  }

}
