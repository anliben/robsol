import { Component, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import { PoStorageService } from '@po-ui/ng-storage';
import { HttpClient } from '@angular/common/http';
import { PoMenuItem, PoMenuComponent, PoChartSerie, PoChartOptions, PoChartType, PoWidgetComponent } from '@po-ui/ng-components';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {
  @ViewChild(PoMenuComponent, { static: true })

  menu!: PoMenuComponent;
  user: string = `${localStorage.getItem('user')}`
  edited: boolean = false
  vendedor: boolean = false

  comissoes: string = environment.api + `Commission/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  pedidos: string = environment.api + `Sales/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  isCollapsed = true;

  chartAreaMOptions: PoChartOptions = {
    axis: {
      maxRange: 700,
      gridLines: 8
    }
  };
  chartAreaMCategories: Array<string> = ['Jan-18', 'Jul-18', 'Jan-19', 'Jul-19', 'Jan-20', 'Jul-20', 'Jan-21'];
  chartAreaMSeries: Array<PoChartSerie> = [
    { label: 'Mensal', data: [550, 497, 532, 550, 530, 565, 572], type: PoChartType.Area },
    {
      label: 'Quadrimestre',
      data: [550, 612, 525, 373, 342, 297, 282],
      type: PoChartType.Line,
      color: 'po-color-07'
    }
  ];

  chartAreaQOptions: PoChartOptions = {
    axis: {
      maxRange: 700,
      gridLines: 8
    }
  };
  chartAreaQCategories: Array<string> = ['Jan-18', 'Jul-18', 'Jan-19', 'Jul-19', 'Jan-20', 'Jul-20', 'Jan-21'];
  chartAreaQSeries: Array<PoChartSerie> = [
    { label: 'Mensal', data: [550, 497, 532, 550, 530, 565, 572], type: PoChartType.Area },
    {
      label: 'Quadrimestre',
      data: [550, 612, 525, 373, 342, 297, 282],
      type: PoChartType.Line,
      color: 'po-color-07'
    }
  ];


  readonly menus: Array<PoMenuItem> = [];
  titulosAbertos: number = 0;
  comissaoBrl: string = '';

  coffeeProduction: Array<PoChartSerie> = [
    { label: 'Brazil', data: 2796, tooltip: 'Brazil (South America)', color: 'color-10' },
    { label: 'Vietnam', data: 1076, tooltip: 'Vietnam (Asia)' },
    { label: 'Colombia', data: 688, tooltip: 'Colombia (South America)' },
    { label: 'Indonesia', data: 682, tooltip: 'Indonesia (Asia/Oceania)' },
    { label: 'Peru', data: 273, tooltip: 'Peru (South America)' }
  ];

  marcas: Array<any> = [
    {
      avatar: '/assets/sabrina-sato.webp',
      name: 'Sabrina Sato',
      description: '30% dos nossos produtos são focados em moda fashion e o design é feito para o rosto do brasileiro.',
      website: 'https://www.robsol.com.br/marcas/sabrinasatoeyewear',
      midia: 'https://www.robsol.com.br/images/Robsol/marcas/Sabrina%20Sato%20Eyewear%20Final-1.mp4'
    },
    {
      avatar: '/assets/fox-eyewear.webp',
      name: 'Fox Eyewear',
      description: 'A FOX Eyewear é projetada para atender o público masculino exigente que temos no mercado hoje em dia.',
      website: 'https://www.robsol.com.br/marcas/foxeyewear',
      midia: 'https://www.robsol.com.br/images/Robsol/marcas/Clipe_FOX_Site.mp4'
    },
    {
      avatar: 'https://www.robsol.com.br/templates/yootheme/cache/_0009_CV8001%20C3-bc81835b.webp',
      name: 'Carmem Vitti',
      description: 'Marca com um design contemporâneo e cores exclusivas. Detalhes incríveis e proteção total a seus olhos, esses são alguns dos diferenciais que tornam cada peça única,como a Carla Diaz.',
      website: 'https://www.robsol.com.br/marcas/carmenvitti',
      midia: ''
    },
    {
      avatar: 'https://www.robsol.com.br/templates/yootheme/cache/lorena_1080px_1-3c51d66b.webp',
      name: 'Trunks Eyewear',
      description: 'Armações coloridas e confortáveis, tornando o uso do óculos muito mais agradável.',
      website: 'https://www.robsol.com.br/marcas/trunks',
      midia: ''
    },
    {
      avatar: 'https://www.robsol.com.br/templates/yootheme/cache/galeria_romano_1080_4-fe1ed5a1.webp',
      name: 'Romano Eyewear',
      description: 'Os modelos são pensados e desenvolvidos buscando antecipar as maiores tendências mundiais e feitos para o rosto do jovem brasileiro.',
      website: 'https://www.robsol.com.br/marcas/romano',
      midia: ''
    },

  ]

  constructor(private router: Router, private storage: PoStorageService, private http: HttpClient) {}

  ngOnInit(): void {

    if(localStorage.getItem('tipo') == 'vendedor'){
      this.vendedor = !this.vendedor

    }
    this.http.get(this.comissoes).subscribe((success: any) => {
      success['items'].forEach((element: any) => {
      })
    }, (err: any) => { })

    const menu = localStorage.getItem('menu_acesso')
    const url = environment.api + `MenusPrt/?CODIGOMENU=${menu}`

    this.http.get(url).subscribe((res: any)=>{
      res.forEach((element: any) => {
        this.menus.push(element)
      });
      this.menus.push( {"label": "loggout","icon": "po-icon-exit","shortLabel": "logout","action": this.clearToken.bind(this),"link": "/login"})
    })

  }


  openTitulos() {
    this.router.navigate(['FINANCIAL'], { queryParams: {status: "Em Aberto"} })
  }
  searchMore(event: any) {
    window.open(`http://google.com/search?q=coffee+producing+${event.label}`, '_blank');
  }

  visiteWebsite(site: any) {
    window.open(`${site}`, '_blank');
  }


  clearToken(menu: PoMenuItem){
    localStorage.setItem('access_token', ' ');
    localStorage.setItem('menu_acesso', ' ');
    localStorage.setItem('cod_vendedor', ' ');
    localStorage.setItem('cod_cliente', ' ');
    localStorage.setItem('user', ' ');
    localStorage.setItem('tipo', ' ');
    localStorage.setItem('cod_usuario', ' ');
  }

}

