//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";

contract StableCoin is ERC20 {
    uint256 feeratePercentage ;
    Oracle public price_in_usd; 
    DepositorCoin public depositorCoin;
    uint256 public constant INITIAL_COLLATERAL_RATIO_PERCENTAGE = 10; 

    constructor(uint256 _feeratePercentage, Oracle priceUSD) ERC20("BinhNguyen", "BNK"){
        feeratePercentage = _feeratePercentage ;
        price_in_usd = priceUSD;
    }

function mint() external payable{
    uint256 fee = _getFee(msg.value);
    uint256 remainingEth = msg.value - fee;
    uint256 mintStableCoinAmount = remainingEth * price_in_usd.getPrice();
    _mint(msg.sender,mintStableCoinAmount);
}

function _getFee(uint256 ethAmount) private view returns(uint256) {
    bool hasDepositors = address(depositorCoin) != address(0) && depositorCoin.supply() > 0;
    if (!hasDepositors) {
        return 0;
    } 
    return (feeratePercentage * ethAmount)/100;
} 

function depositCollateralBuffer() external payable {
    int256 _result = check_surplus_deficit();

    if (_result <= 0) {
        uint256 deficitInUsd = uint256(_result * -1);
        uint256 deficitInEth = deficitInUsd / price_in_usd.getPrice() ;
        uint256 requiredInitialSurplusInUsd = (INITIAL_COLLATERAL_RATIO_PERCENTAGE * totalSupply()) / 100;
        uint256 requiredInitalSurplusInEth = requiredInitialSurplusInUsd / price_in_usd.getPrice() ;

        require (msg.value >= deficitInEth + requiredInitalSurplusInEth, "STC: Initial Collateral ration not met");

        uint256 newInitialSurplusInEth = msg.value - deficitInEth;
        uint256 newInitialSurplusInUsd = newInitialSurplusInEth * price_in_usd.getPrice();

        depositorCoin = new DepositorCoin();
        uint256 mintDepositorCoinAmount = newInitialSurplusInUsd;
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
        return;
    }

    uint256 surplusAmountUSD = uint256 (_result);
    uint256 sender_value_in_usd = msg.value * price_in_usd.getPrice() ;

    uint256 DPC2Mint = sender_value_in_usd / _DPCinUSD(surplusAmountUSD) ;
    depositorCoin.mint(msg.sender, DPC2Mint);
}


function _DPCinUSD(uint256 amountSurplus) private view returns (uint256) {
    uint256 DPCinUSD = amountSurplus / depositorCoin.totalSupply();
    return DPCinUSD;

}

function check_surplus_deficit() private returns (int256) {
    uint256 accountBalanceInUsd = (address(this).balance - msg.value) * price_in_usd.getPrice() ;
    uint256 stableCoinInUsd = totalSupply();
    int256 surplusOrDeficit = int256(accountBalanceInUsd) - int256(stableCoinInUsd) ; 
    return surplusOrDeficit ;
}


function _burn(uint256 burnStableCoinAmount) external {
    int256 deficitOrSurplus = check_surplus_deficit();
    require (deficitOrSurplus >= 0, "STC: Cannot burn while in deficit");
    uint256 ethAmount = burnStableCoinAmount / price_in_usd.getPrice();
    uint256 fee = _getFee(ethAmount);
    uint256 refundingethAmount = ethAmount - fee ;
    burn(msg.sender,burnStableCoinAmount);
    (bool success, ) = msg.sender.call{value : refundingethAmount}("");
    require(success, "Burning Procedure Has Failed");


} 
}